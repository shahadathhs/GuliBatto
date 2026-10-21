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

| Implementation milestone                      | Roadmap phase                                               |
| --------------------------------------------- | ----------------------------------------------------------- |
| Milestone 0 — export smoke test               | Phase 0 — Confirm feasibility                               |
| Milestone 1 — marble test bench               | Phase 1 — The shot must feel good                           |
| Milestone 2 — camera and input                | Phase 2 — Camera and gesture quality                        |
| Milestone 3 — match state and one ruleset     | Phase 3 — A complete match                                  |
| Milestone 4 — second mode and simple opponent | Phase 4 — Two modes, one foundation (and the first AI)      |
| Milestone 5 — production basics               | Phase 5 — Opponent tuning and polish                        |
| Milestone 6 — release candidate               | Phase 6 — Device and browser hardening (Phase 7 is release) |

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

## 6. Milestone 3 — match state and one ruleset

**Build:** match lifecycle, turn ownership, stable board snapshot, rule evaluation, minimal HUD, restart and match result screen. Implement the Guli Khela adapted mode first because it has a public descriptive source to start from.

**Playable without an opponent:** this milestone plays Guli Khela as a single-side score attack: one player, the configured turn limit, claim as many targets as possible. The match still tracks a side and a turn owner, so the AI in Milestone 4 only needs to submit shots for a second side. Hot-seat stays out of scope unless playtests ask for it.

**Implement:**

- valid initial layout;
- legal turn validation;
- score and turn transitions;
- one-time evaluation after settling;
- victory/tie conditions;
- readable scoring feedback;
- tests for hit, miss, pit/goal, restart, and match end.

**Exit gate:** a deterministic test layout leads to the expected score/turn result. Repeating a shot does not double-score. The rules are read from the ruleset rather than embedded in UI scripts.

## 7. Milestone 4 — provisional second mode and simple opponent

**Build:** Batto Challenge as a clearly provisional custom ruleset and a basic local opponent. This is the first version of the AI (legal, plausible shots, configurable error); difficulty tuning and polish follow in Milestone 5. Do not duplicate the match controller for the second mode.

**Implement:**

- same arena and marble systems;
- separate starting layout and scoring evaluation;
- AI picks a legal target/direction/power and commits through the regular shot command;
- imperfect, configurable aim;
- no network or model API dependency.

**Research gate:** before presenting the mode as a faithful version of Batto, interview local players/elders and update `README_GAME_RULES.md` with verified information. Otherwise label it an inspired/custom mode in menus and public descriptions.

## 8. Milestone 5 — production-quality basics

**Build:** main menu, mode selection, tutorial prompt, pause/restart, settings, audio, local save/load, quality fallback, and basic polish.

**Local save:** version the schema, validate values, return default settings on failure, and include a reset option. Test Android and browser storage separately. Do not promise web save reliability in private browsing or where site storage is blocked.

**Performance:**

- low-cost materials and textures;
- restrained dynamic shadows;
- no expensive post-processing as a dependency for readability;
- limit visible props and particles;
- profile actual target devices instead of guessing from editor FPS;
- include a lower-cost setting if profiling shows it is needed.

## 9. Milestone 6 — release candidate

Test on:

- at least one real Android phone representative of the target tier;
- a second Android device if available;
- a current Chromium-based desktop browser;
- another browser engine where practical;
- browser window resize, fullscreen, lost focus, reload, and storage reset.

Check loading time, input latency, restart stability, save recovery, readable UI at common aspect ratios, and no internet connection for the installed Android game. The web build naturally needs a successful initial download unless a previously installed/cached PWA version is available; that cache is not guaranteed to remain forever.

## 10. Implementation guardrails

- Do not introduce a backend.
- Do not author a large number of arenas before shot feel is accepted.
- Do not add a separate camera per view.
- Do not fake physics with transform animation.
- Do not build an admin web dashboard; use Godot Resources and the Inspector first.
- Do not ask an AI tool to rewrite the entire project when a focused script or scene change will do.
- Keep a playable build and a Git commit at every milestone.
