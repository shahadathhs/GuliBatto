# Implementation Plan

## 1. Build the riskiest slice first

Do not build both modes, polished art, menus, and an AI at once. The highest-risk parts are: 3D shot feel, camera/aim gesture conflict, physics settlement, and browser export. Prove those with almost no content first.

## 2. Technical baseline

- **Engine:** a currently supported stable Godot 4.x release, pinned in project notes and used by every contributor/tool session.
- **Language:** GDScript. This is the practical choice for a shared Android/Web release; Godot's current web-export documentation says C# projects cannot be exported to the web.
- **Renderer:** Compatibility, because Godot web exports target WebGL 2 and do not support the Forward+ or Mobile renderers for the web target.
- **Physics:** `RigidBody3D` marbles; static colliders for the ground and walls; physics materials for friction/bounce.
- **Persistence:** local `user://` save with a schema version. No remote storage.
- **Version control:** Git. Commit after each verified milestone, not after a large batch of untested generated code.
- **Web export:** start with a single-threaded export. Thread support may require cross-origin-isolation headers; only enable it if measurement shows a meaningful benefit and hosting can support it.

Official references:

- Web export: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html>
- Android export: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html>
- `RigidBody3D`: <https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html>
- Input examples: <https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html>

## 2a. How this plan maps to the roadmap

[README_ROADMAP.md](README_ROADMAP.md) uses phases and decision gates; this document uses milestones and technical exit checks. They describe the same work.

| Implementation milestone                              | Roadmap phase                                               |
| ----------------------------------------------------- | ----------------------------------------------------------- |
| Milestone 0 — export smoke test                       | Phase 0 — Confirm feasibility                               |
| Milestone 1 — marble test bench                       | Phase 1 — The shot must feel good                           |
| Milestone 2 — camera and input                        | Phase 2 — Camera and gesture quality                        |
| Milestone 3 — match, sides, and Kep                   | Phase 3 — A complete match (Kep)                            |
| Milestone 4 — opponents and Batto                     | Phase 4 — AI opponents and the race                         |
| Milestone 5 — Guli Khela and the distinct-modes check | Phase 5 — The full game, one foundation                     |
| Milestone 6 — production basics (and Quick Dan)       | Phase 6 — Polish and tuning                                 |
| Milestone 7 — release candidate                       | Phase 7 — Device and browser hardening (Phase 8 is release) |

Concrete starting values for settling, the aim handle size, tick rate and the test approach are in [README_ARCHITECTURE.md](README_ARCHITECTURE.md). Tune them in Milestone 1 and record the final numbers there.

## 3. Milestone 0 — export smoke test

**Build:** a blank 3D scene with one camera, one light, a sphere and a ground plane. The repository scaffold (Makefile, lint, GUT, CI) is set up first, so this milestone's only open work is the Android and Web exports on real targets.

**Verify:**

- It exports and loads as an Android debug APK on a real device.
- It exports and loads in a current desktop browser with WebGL 2 support.
- The browser build can be served from the intended host without console errors.
- Touch/mouse focus and resize behaviour are understood.
- The project uses the Compatibility renderer.

**Exit gate:** do not invest in detailed assets until both required builds start successfully. Record issues and pin the exact Godot version/export settings.

## 4. Milestone 1 — physical marble test bench

**Build:** a test scene containing a flat surface, boundaries, two or three marbles, and a repeatable reset layout. Add no main menu and no AI.

**Implement:**

- sphere collision shape and consistent visual radius;
- a single shot command with ground-plane direction and bounded impulse;
- wall and marble collisions;
- friction/bounce calibration;
- “all marbles settled” detection with a timeout;
- a debug readout for linear/angular velocity and shot state;
- reproducible reset between tests.

**Test cases:** straight roll, head-on collision, glancing collision, wall bounce, marble trapped against a boundary, low-power shot, maximum-power shot, rapid repeated restart.

**Exit gate:** a player can predict broad shot behaviour, no body escapes obvious boundaries, and the next shot is never enabled while the previous one is still resolving.

## 5. Milestone 2 — camera and input contract

**Build:** the single CameraRig, shot aiming, camera orbit/zoom/elevation, view presets, reset, and action-follow transition.

**Implement:**

- gesture ownership decided at gesture start;
- aim begins only from active striker/aim handle;
- camera orbit begins only from empty space or a separate desktop mouse button;
- two-finger zoom cannot commit a shot;
- UI pointer events do not reach the world;
- pause/focus loss cancels aim;
- camera limits prevent going under ground or inside major arena geometry.

**Exit gate:** repeat at least 20 aim/orbit/zoom interactions on a phone and desktop without accidental firing or camera drift. Compare shots from top-down and angled views; the same aim parameters must produce the same shot command.

## 6. Milestone 3 — match, sides, and Kep

**Build:** the match lifecycle for 2 to 4 sides, turn order, the board snapshot and shot report, rule evaluation, a minimal HUD, restart, a result screen, and the **Kep** mode (the toss at the hole; see [README_GAME_RULES.md](README_GAME_RULES.md), section 4). Kep goes first because it is the smallest mode and its opening toss is the first step of the other two, so it proves holes, settling, distance ranking and several sides with almost no extra rules.

**All modes stay in the design:** the match controller is written against an N-side layout and a `RuleSet` interface, so Batto and Guli Khela later add a ruleset, a profile and a layout, not a second controller. `KepRules` is the only implementation until Milestone 4.

**No AI yet, so a debug hot-seat:** the milestone is tested with a debug harness where the tester controls each side in turn. This is a test tool, not a player feature, and it is removed from release builds unless playtests ask for hot-seat.

**Implement:**

- the arena with a jalla and a kep, from a rule profile (positions, radii);
- the opening toss and ordering of sides by closeness, a marble in the kep counting as closest;
- the `BoardSnapshot`, `ShotReport` and `SettleDetector` wired to the match state machine;
- Kep scoring (in the kep 3, closest 2, second 1), the round count and the ranking;
- legal turn validation, one-time evaluation after settling, readable result cues;
- tests for: in the kep, closest, a tie, a marble out of bounds, round order, ranking, restart, and no double scoring.

**Exit gate:** a deterministic test layout gives the expected scores and ranking. Repeating a shot never double-counts. The rules are read from the ruleset and profile, not embedded in UI scripts. Four debug sides finish a full match without a stuck state.

## 7. Milestone 4 — opponents and Batto

**Build:** a basic local opponent (1 to 3 AI sides) and the **Batto** route race ([README_GAME_RULES.md](README_GAME_RULES.md), section 5). This is the first AI: legal, plausible shots, configurable error; difficulty tuning follows in Milestone 6. Do not duplicate the match controller.

**Implement:**

- the AI picks a legal target, direction and power and commits through the regular shot command;
- Batto: three holes in a line, route progress `H1 → H2 → H3 → H2 → H1`, hits detected from the `ShotReport`, a bonus shot with the chain cap, finish detection, finishing order, the "last on the route" end and the turn-cap fallback;
- the AI aims at its next hole, or at a rival marble when a hit looks worthwhile;
- imperfect, configurable aim; no network or model API dependency;
- tests for: a hole reached (and its bonus shot), a hole passed over, a hit (and its bonus shot), a chain, the cap of three bonus shots, no bonus shot after finishing, a marble knocked out of bounds, finishing order.

**Check with people:** ask at least one more person who played Batto about the points under "To confirm with players" in section 5 of the rules doc. What they say may change the rules and the tests.

**Exit gate:** a full Batto match against three AI sides finishes and ranks correctly; the AI never takes an illegal shot and sometimes misses.

## 8. Milestone 5 — Guli Khela and the distinct-modes check

**Build:** the **Guli Khela** mode ([README_GAME_RULES.md](README_GAME_RULES.md), section 6) on the same foundation: purses and stakes, the opening toss for each dan, the scatter around the kep, naming the _baad_ marble, evaluating a throw (exactly one other marble touched wins the dan; the _baad_ marble or two or more touched is a fine; no touch passes the turn), a Surrender action, and the end when a side cannot pay or the dan limit is reached.

**Implement:**

- `GuliKhelaRules` and the per-side purse and the pot in the match state;
- the `SCATTER` and `CALLING_BAAD` states, and the `baad_marble_id` on the shot command;
- the AI naming a _baad_ marble and choosing a single marble to touch;
- the pass logic: one attempt per other side per pass, a new pass when all fail, and the scatterer winning the ground after three passes;
- tests for: a clean single touch, the _baad_ marble touched, two marbles touched, no touch, a fine adding a marble, a fine with an empty purse, a dan won (the winner takes the whole ground and the throwing marble returns), all sides failing for one and for three passes, purses changing, a side out of marbles, a surrender, the dan limit.

**Check with people:** ask at least one person who played about the points under "To confirm with players" in section 6 of the rules doc (the fine, the usual stake, whether the scatterer keeps the ground).

**Exit gate:** a full Guli Khela match against an AI finishes with the correct purses at every step. Then the **distinct-modes check**: each mode asks the player to make a different decision (see the table in section 2 of the rules doc). If two modes feel alike, cut the weaker one; do not add another to rescue it.

## 9. Milestone 6 — production-quality basics

**Build:** main menu, mode selection, the About page, tutorial prompt, pause/restart, settings, audio, local save/load, AI tuning, quality fallback, and basic polish. **Quick Dan** (one dan of Guli Khela as a profile) is added here only if short sessions need it.

**Local save:** version the schema, validate values, return default settings on failure, and include a reset option. Test Android and browser storage separately. Do not promise web save reliability in private browsing or where site storage is blocked.

**Performance:**

- low-cost materials and textures;
- restrained dynamic shadows;
- no expensive post-processing as a dependency for readability;
- limit visible props and particles;
- profile actual target devices instead of guessing from editor FPS;
- include a lower-cost setting if profiling shows it is needed.

## 9a. Milestone 7 — release candidate

Test on:

- at least one real Android phone representative of the target tier;
- a second Android device if available;
- a current Chromium-based desktop browser;
- another browser engine where practical;
- browser window resize, fullscreen, lost focus, reload, and storage reset.

Check loading time, input latency, restart stability, save recovery, readable UI at common aspect ratios, and no internet connection for the installed Android game. The web build needs a successful initial download unless a previously installed or cached PWA version is available; that cache is not guaranteed to remain forever.

## 10. Implementation guardrails

- Do not introduce a backend.
- Do not author a large number of arenas before shot feel is accepted.
- Do not add a separate camera per view.
- Do not fake physics with transform animation.
- Do not build an admin web dashboard; use Godot Resources and the Inspector first.
- Do not ask an AI tool to rewrite the entire project when a focused script or scene change will do.
- Keep a playable build and a Git commit at every milestone.

## 11. Release gates

- **Foundation gate:** both exports start on real targets (Milestone 0), the tooling passes in CI, and the Godot version is pinned.
- **Feel gate:** three people unfamiliar with the game can aim and shoot after a short prompt, with the developer silent (Milestones 1 and 2).
- **Rules gate:** a full match of each mode resolves with the correct result, no double counting and no stuck state (Milestones 3 to 5).
- **Distinct modes gate:** each mode asks for a different tactical decision (Milestone 5).
- **Honesty gate:** the About page matches the rules, lists what the author changed, and no mode, screen, or store text claims the rules are official or authentic.
- **Release gate:** tested on a real phone and a real browser; the site's download page points at a verified release; a known-limitations note exists.

## 12. Testing checklist by risk

### Shot and physics

- Straight roll, head-on, glancing, wall bounce, marble trapped on a boundary, low power, maximum power, rapid restart.
- No marble leaves the arena; marbles settle within the timeout; the next shot is never enabled while the previous one resolves.

### Rules

- Hit, miss, pit (rest inside the radius), rolled through the pit, out of ring, rolled back inside the ring, turn limit, tie.
- A shot never scores twice; restart restores layout and score atomically.

### Input and camera

- Aim from empty space does not fire; orbit from the striker does not orbit; two-finger zoom never fires.
- Pause, lost focus and a UI tap cancel an in-progress aim.
- The same aim parameters give the same shot command from every view.

### Save and settings

- First run, corrupted file, newer schema, blocked web storage, reset.

### Devices and browser

- A real Android phone, a second device if available, a Chromium browser and one other engine; resize, fullscreen, lost focus, reload, no network after install.

### Site

- The download page with no release, a private repository, GitHub down, and a valid release; pages without JavaScript; both themes at desktop and mobile widths.

## 13. Avoid scope traps

Do not add a backend, accounts, online play, a dashboard, a campaign, or more arenas before shot feel is accepted. Do not ask an AI tool to rewrite the whole project when a focused script or scene change will do. Do not polish the site before there is a build to download.

## 14. Definition of done for a feature

It behaves correctly after restart and rematch, is clear without developer explanation, has a GUT test for its rule or state, passes `make check`, has been tried on the required input and platform combinations (and says which were not), keeps the docs in step, and respects the guardrails above.
