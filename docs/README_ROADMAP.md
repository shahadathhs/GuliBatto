# Roadmap

This roadmap is milestone-based. Each phase has a decision gate so the project can stop early if the core play does not feel good. Dates are intentionally omitted; the work is solo, and calendar estimates would be false precision.

## Phase 0 — Confirm feasibility

**Goal:** make sure the chosen engine and the two release targets are viable before substantial production work.

Deliverables:

- pinned stable Godot 4.x version;
- Compatibility renderer selected;
- blank 3D Android export installed on a phone;
- blank Web export running in a desktop browser;
- Git repository and working README files.

**Gate:** if WebGL 2 support, rendering, or hosting constraints make browser release impractical, decide now whether to reduce web scope or change the platform plan. Do not wait until the game is finished.

## Phase 1 — The shot must feel good

**Goal:** validate the primary interaction.

Deliverables:

- one dirt-coloured test plane and boundaries;
- two/three marbles;
- aiming/power indicator;
- shot impulse;
- collision and settling;
- debug reset scene.

**Gate:** ask a few people to make several shots. Continue only if shot direction and power feel understandable, and collisions make sense enough that players want another attempt. Fix input/physics before adding content.

## Phase 2 — Camera and gesture quality

**Goal:** support the promised free camera without breaking aiming.

Deliverables:

- orbit, elevation, zoom, reset;
- angled and top-down presets;
- low view with ground/arena safety limits;
- temporary shot-follow camera;
- mobile and desktop gesture arbitration.

**Gate:** camera view changes must not affect physical outcomes. Accidental shots during camera use are release blockers.

## Phase 3 — A complete match

**Goal:** turn the test bench into a small game. Guli Khela is a single-side score attack here; there is no opponent until Phase 4.

Deliverables:

- match and turn state machine;
- initial layout;
- score/victory logic;
- minimal HUD and menus;
- deterministic test setups;
- restart/rematch.

**Gate:** a full round can start, resolve, display a correct result, and restart without stuck states or double scoring.

## Phase 4 — Two modes, one foundation

**Goal:** make the two modes distinct without duplicating the game.

Deliverables:

- adapted Guli Khela pit-and-strike mode;
- provisional Batto Challenge circle-knockout mode;
- shared physics, camera, and turn lifecycle;
- rule profiles that separate mode data and scoring behaviour;
- a first simple local AI so the second side can be played alone.

**Gate:** each mode should ask the player to make a different tactical decision. If the modes feel like the same rule with different labels, refine them before adding a third mode.

**Cultural validation:** interview people familiar with Batto and local Guli Khela variants. Keep the mode labelled provisional/inspired if standard rules cannot be verified.

## Phase 5 — Opponent tuning and polish

**Goal:** make the game playable alone and understandable to a first-time player. The first AI is built in Phase 4 (Implementation Milestone 4); this phase tunes it.

Deliverables:

- AI difficulty and error tuning;
- first-use controls prompt;
- scoring cues and turn transitions;
- basic sound and restrained impact feedback;
- settings and local save;
- reset-save path.

**Gate:** the AI should make legal, plausible shots and occasionally miss. If it takes too long to build, use a smaller heuristic rather than holding the whole release hostage.

## Phase 6 — Device and browser hardening

**Goal:** confirm the actual target builds are comfortable to play.

Deliverables:

- Android release-candidate package;
- Web release-candidate export;
- low/medium visual tuning as required;
- test matrix for input, viewport, reload, storage, pause, and restart;
- known-limitations note.

**Gate:** do not call it shipped until there are successful tests on a real phone and a real browser. Editor playback alone does not prove export quality.

## Phase 7 — Release and observe

**Goal:** publish a small, stable first release.

Deliverables:

- the marketing site live with a working download page (see [README_RELEASE.md](README_RELEASE.md));
- app icons, store/web description, screenshots, privacy statement appropriate to the actual data collection (ideally none beyond local storage);
- final rules labels that do not overclaim authenticity;
- versioned build and backup of signing credentials;
- basic issue-reporting route that does not require an in-game account.

After release, decide from player feedback whether to add another arena, local pass-and-play, verified variants, or improved AI. Avoid starting several of these at once.

## Not on the roadmap unless justified

- backend or cloud infrastructure;
- online matchmaking/leaderboards;
- large creator dashboard;
- human character models;
- dozens of arenas or a content campaign;
- monetisation and in-game economy;
- online AI service.

## Roadmap rule

The project moves forward when the current milestone meets its exit conditions, not because its checklist is long. A playable and understandable marble game is a stronger result than a large folder of half-integrated systems.
