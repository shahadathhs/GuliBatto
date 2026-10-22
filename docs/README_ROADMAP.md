# Roadmap

> **Replanned 2026-10-21.** The goal is the four modes, each represented properly, on Android and the web, with the same information on the web and in the app, and nothing extra ([`README_PROJECT_OVERVIEW.md`](README_PROJECT_OVERVIEW.md)). Phases are numbered like the implementation milestones in [`README_IMPLEMENTATION.md`](README_IMPLEMENTATION.md): Phase _n_ is Milestone _n_. Each phase has a gate. Dates are omitted; the work is solo and calendar estimates would be false precision.

## Where things stand

**Built**

- The shot, settling and physics core, with tests (Phase 1) and the camera and input (Phase 2), checked headless and in rendered frames; **not played by hand on a phone**.
- Kep and Batto, complete as playable modes against computer sides, with their rules and match flow, and the menu, HUD, results, About, pause and settings screens in light and dark (Phase 3).
- A first version of the website: home, how to play, about, download, privacy, and a play page that frames Godot's default page.
- The Android and web builds are produced by CI and published in the release `v0.0.1`. Only the web export has been run, in a headless browser; the APK has not been run on a real device.
- The site is live at <https://playgulibatto.vercel.app>.
- Checks: lint, token and colour checks, 87 game tests, site tests and a smoke test, and a CI pipeline that passes on `main` and has published a release.

**Not built**

- Guli Khela and Quick Dan.
- The shared content source, the large Home, per-game and How to play pages, Contact, the in-app pages, the site-native browser loader, and the all-platform download page.
- Sound, saved settings, and checking the rules with people who played.

## Phase 0 — Android and web build and run

**Goal:** one Godot project that exports, from CI, to Android and the web, and each export starts and plays a toss.

Deliverables:

- pinned Godot version and export presets for Android and the web;
- a CI that builds each in the Godot container, with the site rebuild hook and releases ([`CI.md`](CI.md), [`DEPLOY.md`](DEPLOY.md));
- each build tried on a real target: an Android phone and a desktop browser;
- a note of what each OS shows for an unsigned build.

**Gate:** both builds launch and a toss can be played. Status: the web export is built and played in headless Chrome; the APK is open.

## Phase 1 — The shot must feel good

**Goal:** validate the primary interaction.

Deliverables: marbles with real physics, a bounded shot impulse, collision and settling, a debug readout, and a repeatable reset.

**Gate:** a few people make several shots; direction and power feel understandable and collisions make sense. Status: built and tested; **the hand check is open.**

## Phase 2 — Camera and gesture quality

**Goal:** the promised free camera without breaking aiming.

Deliverables: orbit, elevation, zoom, reset, three views, and gesture arbitration on touch and mouse.

**Gate:** camera view changes never affect physical outcomes, and accidental shots during camera use are release blockers. Status: built and tested through the real input path; **the hand check on a phone is open.**

## Phase 3 — Kep, complete

**Goal:** the first mode, properly.

Deliverables: the toss at the hole, scoring and rounds, computer opponents, and the full screen set.

**Gate:** the acceptance list in the overview (section 3) for Kep. Status: built; the hand check and the explanations (How to play, the first-use prompt per mode) are open.

## Phase 4 — Batto, complete

**Status:** built and tested; the hand check on a phone and the check with players are open.

**Goal:** the three-hole race, properly.

Deliverables: three holes in a line and the route, route progress on screen, hits and bonus shots (a hit, or reaching a hole), the chain cap, finishing order and the end, computer sides that choose between the hole and a hit, result cues, and tests for every rule.

**Gate:** the acceptance list for Batto; a full match against three computer sides ends and ranks correctly. Check the open points in [`README_GAME_RULES.md`](README_GAME_RULES.md) with at least one more person who played.

## Phase 5 — Guli Khela and Quick Dan, complete

**Goal:** the full stake game, properly, and its short form.

Deliverables: purses and stake, the opening toss for each dan, the scatter, naming the _baad_ marble, a clean touch and a fine, winning a dan, the three-pass rule, surrender and the end of a match, computer sides that name a _baad_ and touch one marble, Quick Dan as a profile, and tests for every rule.

**Gate:** the acceptance list for both; a full Guli Khela match against computer sides keeps the right purses at every step. Then the distinct-modes check: each of the four asks for a different decision.

## Phase 6 — The pages, on the web and in the app

**Goal:** everything the plan says to teach and say, in both places, from one source.

Deliverables ([`README_WEB_AND_APP_PLAN.md`](README_WEB_AND_APP_PLAN.md)):

- the shared content source and diagram format;
- the large Home page, a page for each game, the very large How to play, About, Contact and Privacy on the site;
- the same How to play, mode info, About, Contact and Privacy in the app, and the links between the web and the apps;
- the browser game loading on the site's own canvas, with progress, checks and retry;
- the download page for the APK and the browser version;
- the basics finished: sound, saved settings and a reset.

**Gate:** a visitor can learn all four games from the site alone and the app teaches the same, from the same words, and a check proves they match.

## Phase 7 — Release

**Goal:** a stable first release on Android and the web.

Deliverables:

- automatic release when the version changes: an APK, the web export and a checksum file ([`CI.md`](CI.md));
- the site live, with the download page listing the APK and the browser version;
- hand testing on a real phone and a desktop browser; a known-limitations note;
- the rules checked with people who played, and the About page updated from what they said;
- icons, a share image, and the privacy statement.

**Gate:** do not call it shipped until each build has been run by a person. Editor playback and headless tests do not prove it.

## Not on the roadmap

Pass-and-play, other languages, statistics and achievements, extra arenas or skins, a campaign, online play, accounts, leaderboards or any backend, human characters, monetisation, a dashboard. Adding one is a new decision recorded in the overview first.

## Roadmap rule

The project moves forward when the current phase meets its gate, not because its checklist is long. Four modes that are right, explained and playable everywhere are worth more than many half-finished parts.
