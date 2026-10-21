# Guli & Batto — Architecture

> **Rules:** what counts as a legal shot, a score, or a win is in [README_GAME_RULES.md](README_GAME_RULES.md); the player-facing behaviour is in [README_GAMEPLAY_FEATURES.md](README_GAMEPLAY_FEATURES.md). This document covers structure only.
>
> **Architecture goal:** one small Godot game with one simulation, one camera rig, and four modes (Kep, Batto, Guli Khela, and Quick Dan as a profile of Guli Khela) built on three rulesets that share a match lifecycle for two to four sides. Everything runs offline on the device.
>
> **Status:** proposed. Values marked _initial_ are starting points to tune in Milestone 1, not measured facts.

## 1. Shape of the project

```text
GuliBatto/
├── game/                      # the Godot project (project.godot lives here)
│   ├── scenes/                # .tscn files: main, arena, marble, ui screens
│   ├── scripts/
│   │   ├── core/              # pure logic, no nodes: shot command, settle check, board snapshot
│   │   ├── match/             # match state machine, turn ownership, rule evaluation
│   │   ├── rules/             # one script per ruleset (Kep, Batto, Guli Khela); they read a profile, a snapshot and a shot report
│   │   ├── physics/           # marble body, arena colliders, shot applier
│   │   ├── camera/            # CameraRig and view presets
│   │   ├── input/             # gesture arbiter, aim controller
│   │   ├── ai/                # shot chooser for the local opponent
│   │   ├── ui/                # HUD, menus, aim feedback (draw only, no rules)
│   │   └── save/              # versioned local save
│   ├── resources/
│   │   └── rules/             # RuleProfile .tres files, one per mode
│   ├── assets/                # audio, textures, fonts (licences recorded beside them)
│   ├── addons/gut/            # test framework
│   └── tests/                 # GUT tests
├── web/                       # the website (Next.js): the pages, and the game in the browser
├── content/                   # (planned) the shared words and diagrams for the site and the app
├── design/                    # tokens.json, the one source of colours (generates the Godot palette and web CSS)
├── scripts/                   # version bump, Android CI setup
├── docs/
├── VERSION                    # source of truth for releases
├── Makefile                   # the command surface; CI runs the same targets
└── AGENTS.md
```

There is no backend. The only web code is the website in `web/`, which never contains game logic: it renders the shared content and loads the game's browser export. Rule and arena variants are authored as Godot Resources in the Inspector.

## 2. Layers and dependencies

Dependencies point downward only. A lower layer never imports a higher one.

```text
 ui, camera, input, ai        (presentation and intent)
          │
        match                 (turn lifecycle, owns the state machine)
          │
 rules, core                  (decisions from data; pure functions on a snapshot)
          │
       physics                (RigidBody3D marbles, colliders, applying a shot)
```

- **`core`** holds plain `RefCounted` classes with no scene tree access, so GUT tests can run them without loading a scene. `ShotCommand`, `BoardSnapshot`, `ShotReport`, `SettleDetector` and `RuleResult` live here.
- **`rules`** never touches nodes. A ruleset takes a `RuleProfile`, a `BoardSnapshot` and a `ShotReport` and returns a `RuleResult`. UI scripts never contain scoring logic.
- **`match`** is the only place that changes turn, score, or phase.
- **`physics`** is the only place that applies impulses. Camera, UI, and AI never call `apply_impulse`.
- **`ui`** reads match state through signals and draws it. It sends intent (aim released, restart pressed) and never edits state.

## 3. Core concepts

### Shot command

A shot is a value, not an event in a script:

```text
ShotCommand { side, marble_id, direction: Vector2 (unit, ground plane), power: float (0..1), baad_marble_id: int (Guli Khela only, else -1) }
```

- Built by the aim controller or the AI. In Guli Khela the side names the _baad_ marble first and the command carries it; the match refuses a Guli Khela shot with no _baad_ named. Validated by the match (state is `WAITING_FOR_SHOT`, side is current, power inside bounds, direction is normalised).
- Converted to an impulse in one place (`shot_applier.gd`) from `power` and tuning constants on the marble.
- The command has no camera or screen data. The aim controller converts a pointer position to a ground-plane point and then to a direction before it makes the command, so the same aim from any view gives the same command.

### Board snapshot and shot report

`BoardSnapshot` is a plain record of every marble (id, side, position, resting state) taken once, after the board settles. `ShotReport` is a plain record of what the shot's marble touched during its own shot, in order (for example `[marble_of_side_2, marble_of_side_3]`). Contact callbacks in `physics/` only append to the report; they never score. Rule evaluation reads the snapshot and the report, never live nodes. This is what makes "evaluate once" testable: tests build both by hand and check the result without running physics.

A **hit** is "the shooter's marble touched another side's marble" as read from the report. A marble that is only nudged by a third marble is not a hit by the shooter.

### Rule profile

`RuleProfile` is a `Resource` with the data a mode needs: number of sides, layout (marble ids, sides, start positions), the jalla and the holes (positions and radii), the **route** as an ordered list of hole indices (Batto: `[0, 1, 2, 1, 0]`), kep points and round count (Kep), purse size, stake size, scatter radius, fine size and dan limit (Guli Khela), boundary shape and radius, turn limit and per-side turn cap, bonus-shot rules (a hit grants one, reaching a hole grants one, the chain cap of three), the number of passes before the scatterer keeps the ground, score values, the tie-break policy. A profile holds data only. The decision code is in `rules/`.

Three rulesets exist: `KepRules` (toss and points), `BattoRules` (route race) and `GuliKhelaRules` (stake, _baad_, fines, purses). Quick Dan is a `RuleProfile` for `GuliKhelaRules` that ends after the first dan. They share one interface: `evaluate(profile, snapshot, report, state) -> RuleResult`, where `state` is what the match keeps between shots: per-side progress (route index, score, finished), per-side purse and the pot (Guli Khela). The result says what changed (progress, score, a bonus shot, a win, a fine, a finish, a new pass) and who plays next. Do not build a generic rules engine.

### Sides and turn order

A side is an index with an owner (human or AI), a marble colour and mark, and its own progress record (and, in Guli Khela, its purse). The match keeps an ordered list of sides. The order comes from the opening toss (closest to the first hole or the kep first) for every mode; the toss is repeated at the start of each Guli Khela dan. A side that has finished is skipped. Every side, human or AI, acts through the same `ShotCommand`.

### Match state machine

```text
MENU → SETUP → OPENING_TOSS → (SCATTER → CALLING_BAAD, Guli Khela only) → WAITING_FOR_SHOT → SHOT_IN_FLIGHT → SETTLING → EVALUATING → RESULT_CUE ─┬→ WAITING_FOR_SHOT (same side: bonus shot; or next side)
                                                                                                                                              ├→ OPENING_TOSS (next dan)
                                                                                                                                              └→ MATCH_OVER
                                         PAUSED (from any state except MATCH_OVER; resumes the previous state)
```

- Only `WAITING_FOR_SHOT` accepts a shot or an aim gesture, and only from the side whose turn it is.
- `OPENING_TOSS` collects one toss per side, then orders the sides by closeness to the first hole or the kep.
- `SCATTER` (Guli Khela) moves the stake marbles from the purses to the ground and places them around the kep with a seeded layout; no side plays a shot. `CALLING_BAAD` waits for the active side to name the _baad_ marble.
- `SETTLING` ends when the settle detector reports stable or the timeout fires.
- `EVALUATING` runs once per shot. A guard flag makes a second call a no-op, so a shot can never score or advance twice. A bonus shot is a new `WAITING_FOR_SHOT` for the same side, with a counter checked against the chain cap.
- Restart builds a fresh match from the profile. It never reuses partial turn state.

### Settle detector

A board is settled when every marble stays below both thresholds for a continuous window. **Tuned in Milestone 1** (all in `core/tuning.gd`): linear speed below 0.1 m/s, angular speed below 1.0 rad/s, held for 0.3 s. A hard timeout (8 s) ends settling anyway: the bench freezes all marbles and evaluates the board as it is (the match will also log it in debug builds). A stuck turn is a bug in the design, so the timeout is a safety net and not the normal path. In the tests no shot reaches it; a full-power shot settles in about 4 s.

## 4. Physics

- **Bodies:** `RigidBody3D` marbles with `SphereShape3D`. Ground and walls are `StaticBody3D`. Friction and bounce come from shared `PhysicsMaterial` resources, not per-script constants.
- **Tuned values (Milestone 1, `core/tuning.gd`):** world scaled so a marble (radius 0.2 m, mass 1) is about a fifteenth of the arena radius (3.0 m). A power-1.0 shot gives 6 m/s; linear damping 1.1, angular damping 0.15, friction 0.4, marble bounce 0.5, wall bounce 0.4. On this setup a marble rolls about 4.5 m at full power, nearly linear in power (power 0.2 rolls 0.8 m, 0.55 rolls 2.4 m, 0.85 rolls 3.8 m), and settles in 2.6 to 4.1 s. A 2.5 m toss is about power 0.55. Heavier damping made full-power shots stop after about 2 m and drained the energy from collisions, and angular damping above about 0.5 dragged rolling marbles to a stop; both were measured, not guessed.
- **Physics engine: Jolt**, set explicitly in `project.godot`. The default engine made marbles drift sideways (0.11 m over a 1.7 m straight roll) on the heightmap ground, which has the kep's dish in it; Jolt did not. Whether Jolt is available in the web export is unverified: check it when the first browser export is built (Milestone 0).
- **The kep is a real dish:** the ground height comes from `GroundField` (flat, with a smooth dish of radius 0.45 m and depth 0.04 m at each hole), and both the collision shape and the visible mesh are sampled from it. Measured with a toss from the line: a well-aimed shot of power about 0.5 to 0.7 drops in and stays, a hard shot (0.85 and up) rolls through and skips, a weak one stops short. Deeper dishes (0.12 m) captured every shot.
- **Resets:** all marbles are held (frozen) at their places and released together on the next physics step, because resetting them one at a time lets two overlap for an instant and push each other.
- **Tests run with `--fixed-fps 60`,** which drops real-time pacing and keeps the physics step. Never use `Engine.time_scale` in tests: it changes the physics (a shot that settles in 3 s at scale 1 never settled at scale 6).
- **Tunnelling:** marbles use continuous collision detection (`continuous_cd`). Walls have real thickness. A test fires a maximum-power shot at a wall at a shallow angle.
- **Tick rate:** start at the Godot default of 60 physics ticks per second and test 120 on the target phone. Rule tests never depend on exact positions; they check outcomes (in or out of the pit, inside or outside the ring) against margins.
- **Determinism:** the game does not promise identical trajectories across devices. The same board and the same shot give the same _kind_ of outcome, and the rules tolerate small differences. Tests therefore use hand-built snapshots for rule logic, and separate physics tests with tolerances for shot feel.
- **Pit:** an `Area3D` trigger plus a rest check. A marble counts as in the pit only if the snapshot shows it resting inside the pit radius. Passing through is not a claim.
- **Irregular ground:** the first arena keeps a flat collision surface under a visually varied mesh. Visual unevenness must not change rolling until the physics is calibrated.

## 5. Camera and input

### CameraRig

One `Node3D` rig with a `Camera3D` child. A view preset is data (yaw, pitch, distance, target) the rig eases toward. Orbit, zoom, elevation and reset change the same rig values. There is one camera in the project.

- Elevation and distance are clamped; the low view has a minimum height above the ground and a minimum distance from the walls.
- Shot-follow stores the player's current view, eases to follow the active marble while the state is `SHOT_IN_FLIGHT` or `SETTLING`, then eases back. It is skippable and can be disabled in settings.
- The rig reads no match state except the phase it is told about. It never moves a marble.

### Gesture arbitration

`GestureArbiter` decides at gesture start who owns the pointer and holds that decision until release or cancel.

| Start of gesture                                             | Owner                                                 |
| ------------------------------------------------------------ | ----------------------------------------------------- |
| On the active striker's aim handle, state `WAITING_FOR_SHOT` | Aim controller                                        |
| On empty arena (touch) or right/middle mouse (desktop)       | Camera orbit                                          |
| Two touches                                                  | Camera zoom; never commits a shot                     |
| On a UI control                                              | UI; the event is consumed and never reaches the world |

The aim handle is a screen-space circle larger than the visible marble (_initial:_ about 56 px radius) so a small or distant striker is still easy to grab. Pause, lost focus, or a state change cancels the active gesture and resets the aim preview.

## 6. Opponents

One to three AI sides can play (Batto uses up to three). `ai/` produces a `ShotCommand` for the current side and submits it through the same path as the player. It generates a few candidate directions toward targets, scores them with simple distance and angle heuristics, picks one, then adds a configurable error to direction and power. It reads the board snapshot only, and no network, model, or search is involved. In Batto the main candidate is a shot at the side's next hole; a shot at a rival marble is considered when it is close and a hit looks worthwhile, since a hit gives a bonus shot and sends the rival away. Each AI side has its own configurable error.

## 7. Local save

A single file at `user://save.json`, with `schema_version`, settings, and small match statistics. The save script validates every field, falls back to defaults on any failure, and exposes a reset. Nothing is uploaded. Web storage can be blocked or cleared (private browsing, site data cleared); the game must start normally without it.

## 8. Targets and exports

One Godot project exports to five platforms. All use the Compatibility renderer and Jolt physics, and GDScript only (C# cannot export to the web).

| Target  | Notes                                                                                                   |
| ------- | ------------------------------------------------------------------------------------------------------- |
| Android | The first target. arm64. Debug-signed APK.                                                              |
| Web     | WebGL 2, single-threaded export (no special headers). The full game, run by the site on its own canvas. |
| Windows | x86-64, unsigned.                                                                                       |
| macOS   | Unsigned `.app` in a zip.                                                                               |
| Linux   | x86-64.                                                                                                 |

Export presets exclude `tests/` and `addons/`. Pin the exact Godot version in `project.godot`, the Makefile and CI together. The pipeline and release files are in [CI.md](CI.md).

## 9. Testing approach

- **GUT** runs headless (`make game-test`). Test files live in `game/tests/`, one per unit.
- **Rule tests** build a `BoardSnapshot` by hand and assert the `RuleResult`: hit, miss, pit, out of ring, restart, match end, no double scoring.
- **Match tests** drive the state machine with scripted commands and a fake settle signal.
- **Physics tests** run a short real simulation and assert broad outcomes with tolerances (the marble stopped, did not escape the boundary, head-on transfers more momentum than glancing). They are slower and kept few.
- **Input and camera** are checked by hand on a phone and a desktop against the Milestone 2 list in [README_IMPLEMENTATION.md](README_IMPLEMENTATION.md). Do not claim a device or browser test that was not run.

## 10. Web, tokens and releases

- **`web/`** is a Next.js site. It never imports game code and holds no rules. It renders the shared `content/` (the same words and diagrams the app shows) and runs the game's browser export on its own canvas. Plan: [README_WEB_AND_APP_PLAN.md](README_WEB_AND_APP_PLAN.md).
- **`content/`** (planned) holds the pages' words and named diagrams as JSON blocks, rendered by the site and by the app, with a check that they match.
- **Design tokens** live in `design/tokens.json`. `scripts/tokens.mjs` generates the Godot palette (`Palette.get_color(&"glaze", Palette.Scheme.LIGHT)`) and the web CSS variables; CI fails on drift, on a failing contrast pair, and on any hand-written colour. Nothing in `core`, `rules`, `match` or `physics` reads a colour.
- **Releases:** `VERSION` is the source of truth; CI builds the APK and the web export from `main`. See [CI.md](CI.md).
- **Concept renders** are generated by `scripts/design/` from the token values; they are design targets, not game captures.

## 11. What this architecture deliberately does not have

A server, accounts, analytics, a generic rules engine, a scripting layer for user-made rules, a second camera, per-view physics settings, animation-driven scoring. Each would need an explicit decision recorded in [README_ROADMAP.md](README_ROADMAP.md) first.
