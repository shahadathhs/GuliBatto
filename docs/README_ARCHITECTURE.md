# Guli & Batto — Architecture

> **Rules:** what counts as a legal shot, a score, or a win is in [README_GAME_RULES.md](README_GAME_RULES.md); the player-facing behaviour is in [README_GAMEPLAY_FEATURES.md](README_GAMEPLAY_FEATURES.md). This document covers structure only.
>
> **Architecture goal:** one small Godot game with one simulation, one camera rig, and two rulesets that share a match lifecycle. Everything runs offline on the device.
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
│   │   ├── rules/             # one script per ruleset; they read a profile and a snapshot
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
├── web/                       # marketing site (Next.js): home, how to play, download, privacy
├── scripts/                   # version bump, Android CI setup
├── docs/
├── VERSION                    # source of truth for releases
├── Makefile                   # the command surface; CI runs the same targets
└── AGENTS.md
```

There is no backend. The only web code is the marketing site in `web/`, which never runs the game logic. Rule and arena variants are authored as Godot Resources in the Inspector.

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

- **`core`** holds plain `RefCounted` classes with no scene tree access, so GUT tests can run them without loading a scene. `ShotCommand`, `BoardSnapshot`, `SettleDetector` and `RuleResult` live here.
- **`rules`** never touches nodes. A ruleset takes a `RuleProfile` and a `BoardSnapshot` and returns a `RuleResult`. UI scripts never contain scoring logic.
- **`match`** is the only place that changes turn, score, or phase.
- **`physics`** is the only place that applies impulses. Camera, UI, and AI never call `apply_impulse`.
- **`ui`** reads match state through signals and draws it. It sends intent (aim released, restart pressed) and never edits state.

## 3. Core concepts

### Shot command

A shot is a value, not an event in a script:

```text
ShotCommand { side, marble_id, direction: Vector2 (unit, ground plane), power: float (0..1) }
```

- Built by the aim controller or the AI. Validated by the match (state is `WAITING_FOR_SHOT`, side is current, power inside bounds, direction is normalised).
- Converted to an impulse in one place (`shot_applier.gd`) from `power` and tuning constants on the marble.
- The command has no camera or screen data. The aim controller converts a pointer position to a ground-plane point and then to a direction before it makes the command, so the same aim from any view gives the same command.

### Board snapshot

`BoardSnapshot` is a plain record of every marble (id, owner, position, resting state) taken once, after the board settles. Rule evaluation reads only the snapshot, never live nodes. This is what makes "evaluate once" testable: tests build a snapshot by hand and check the result without running physics.

### Rule profile

`RuleProfile` is a `Resource` with the data a mode needs: layout (marble ids, owners, start positions), pit position and radius, boundary shape and radius, turn limit, score values, whether a success keeps the turn, the tie-break policy. A profile holds data only. The decision code is in `rules/`.

Two rulesets exist: `GuliKhelaRules` and `BattoChallengeRules`. They share one interface (`evaluate(profile, snapshot, last_shot) -> RuleResult`). Do not build a generic rules engine.

### Match state machine

```text
MENU → SETUP → WAITING_FOR_SHOT → SHOT_IN_FLIGHT → SETTLING → EVALUATING → RESULT_CUE ─┬→ WAITING_FOR_SHOT
                                                                                       └→ MATCH_OVER
                                         PAUSED (from any state except MATCH_OVER; resumes the previous state)
```

- Only `WAITING_FOR_SHOT` accepts a shot or an aim gesture.
- `SETTLING` ends when the settle detector reports stable or the timeout fires.
- `EVALUATING` runs once per shot. A guard flag makes a second call a no-op, so a shot can never score twice.
- Restart builds a fresh match from the profile. It never reuses partial turn state.

### Settle detector

A board is settled when every marble stays below both thresholds for a continuous window. _Initial values:_ linear speed below 0.05 m/s, angular speed below 0.5 rad/s, held for 0.5 s. A hard timeout (_initial:_ 8 s) ends settling anyway: the match freezes all marbles, logs the event in debug builds, and evaluates the board as it is. A stuck turn is a bug in the design, so the timeout is a safety net and not the normal path.

## 4. Physics

- **Bodies:** `RigidBody3D` marbles with `SphereShape3D`. Ground and walls are `StaticBody3D`. Friction and bounce come from shared `PhysicsMaterial` resources, not per-script constants.
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

## 6. Opponent

`ai/` produces a `ShotCommand` for the current side and submits it through the same path as the player. It generates a few candidate directions toward targets, scores them with simple distance and angle heuristics, picks one, then adds a configurable error to direction and power. It reads the board snapshot only, and no network, model, or search is involved.

## 7. Local save

A single file at `user://save.json`, with `schema_version`, settings, and small match statistics. The save script validates every field, falls back to defaults on any failure, and exposes a reset. Nothing is uploaded. Web storage can be blocked or cleared (private browsing, site data cleared); the game must start normally without it.

## 8. Targets and exports

| Target  | Notes                                                                                                   |
| ------- | ------------------------------------------------------------------------------------------------------- |
| Android | Primary. Compatibility renderer, arm64. Debug APK first.                                                |
| Web     | WebGL 2, Compatibility renderer, single-threaded export first. GDScript only (C# cannot export to web). |
| Desktop | Used for development and as the browser-equivalent control test.                                        |

Export presets exclude `tests/` and `addons/`. Pin the exact Godot version in `project.godot`, the Makefile, and CI together.

## 9. Testing approach

- **GUT** runs headless (`make game-test`). Test files live in `game/tests/`, one per unit.
- **Rule tests** build a `BoardSnapshot` by hand and assert the `RuleResult`: hit, miss, pit, out of ring, restart, match end, no double scoring.
- **Match tests** drive the state machine with scripted commands and a fake settle signal.
- **Physics tests** run a short real simulation and assert broad outcomes with tolerances (the marble stopped, did not escape the boundary, head-on transfers more momentum than glancing). They are slower and kept few.
- **Input and camera** are checked by hand on a phone and a desktop against the Milestone 2 list in [README_IMPLEMENTATION.md](README_IMPLEMENTATION.md). Do not claim a device or browser test that was not run.

## 10. What this architecture deliberately does not have

A server, accounts, analytics, a generic rules engine, a scripting layer for user-made rules, a second camera, per-view physics settings, animation-driven scoring. Each would need an explicit decision recorded in [README_ROADMAP.md](README_ROADMAP.md) first.
