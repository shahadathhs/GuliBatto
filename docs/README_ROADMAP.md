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

## Phase 3 — A complete match (Kep)

**Goal:** turn the test bench into a small game with the simplest mode. Kep is a toss at a hole for 2 to 4 sides; it proves holes, settling, distance ranking and turn order, and its toss opens the other modes. This phase is tested with a debug hot-seat, because the AI comes in Phase 4.

Deliverables:

- match and turn state machine for N sides;
- the jalla and kep arena, the opening toss, Kep scoring and ranking;
- minimal HUD and menus;
- deterministic test setups;
- restart/rematch.

**Gate:** a full four-side Kep match can start, resolve, display a correct ranking, and restart without stuck states or double counting.

## Phase 4 — AI opponents and the race

**Goal:** make the game playable alone, and add Batto on the same foundation.

Deliverables:

- one to three local AI sides using the same shot interface, with configurable error;
- Batto: three holes, route progress, hits and bonus shots, finishing order;
- shared physics, camera, and turn lifecycle;
- rule profiles that separate mode data and scoring behaviour.

**Gate:** a full Batto match against three AI sides finishes and ranks correctly, and the AI sometimes misses. If the AI takes too long, use a smaller heuristic rather than holding the release hostage.

**Check with people:** ask at least one more person who played Batto about the points under "To confirm with players" in [README_GAME_RULES.md](README_GAME_RULES.md), section 5.

## Phase 5 — The full game, one foundation

**Goal:** add Guli Khela, the full traditional-style game, and prove the modes are distinct.

Deliverables:

- Guli Khela: purses and stakes, the scatter, naming the _baad_ marble, fines, winning a dan, surrender;
- the distinct-modes check from [README_GAME_RULES.md](README_GAME_RULES.md), section 2.

**Gate:** each mode asks the player to make a different tactical decision. If two feel alike, cut the weaker one before adding anything.

**Checking with people:** ask people who played these games how they played them, and update the rules and the About page. See [README_GAME_RULES.md](README_GAME_RULES.md), section 10.

## Phase 6 — Polish and tuning

**Goal:** make the game understandable to a first-time player.

Deliverables:

- AI difficulty and error tuning;
- Quick Dan, only if short sessions need it;
- the About page in the game and on the site;
- first-use controls prompt;
- scoring cues and turn transitions;
- basic sound and restrained impact feedback;
- settings and local save;
- reset-save path.

**Gate:** a first-time player completes a match without being told how, and the AI makes legal, plausible shots.

## Phase 7 — Device and browser hardening

**Goal:** confirm the actual target builds are comfortable to play.

Deliverables:

- Android release-candidate package;
- Web release-candidate export;
- low/medium visual tuning as required;
- test matrix for input, viewport, reload, storage, pause, and restart;
- known-limitations note.

**Gate:** do not call it shipped until there are successful tests on a real phone and a real browser. Editor playback alone does not prove export quality.

## Phase 8 — Release and observe

**Goal:** publish a small, stable first release.

Deliverables:

- the marketing site live with a working download page (see [CI.md](CI.md));
- app icons, store/web description, screenshots, privacy statement appropriate to the actual data collection (ideally none beyond local storage);
- the About page matching the rules and listing what the author changed;
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
