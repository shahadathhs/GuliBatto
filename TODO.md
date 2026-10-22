# TODO

The goal is the four modes, represented properly, on Android and the web, with the same pages on the web and in the app, and nothing extra. The plan is in [docs/README_PROJECT_OVERVIEW.md](docs/README_PROJECT_OVERVIEW.md) and [docs/README_ROADMAP.md](docs/README_ROADMAP.md); the build order is in [docs/README_IMPLEMENTATION.md](docs/README_IMPLEMENTATION.md). Tick items as they are done.

**Replanned 2026-10-21.** The docs describe the new plan. The code and the CI workflow still reflect the older, smaller plan until the phases below are done.

## Built so far

- [x] The shot, settling and physics core with tests (Phase 1) and camera and input (Phase 2); checked headless and in rendered frames, **not played by hand on a phone**
- [x] Kep, complete as a playable mode against two computer sides, with the full screen set in light and dark (Phase 3)
- [x] Batto, playable against two computer sides: the opening toss, the race along three holes and back, bonus shots, finishing order (Phase 4), on its own large rectangular board with small marbles and deep numbered holes, four marbles wide and 13 m apart, shot from the hole's edge; 110 game tests in all
- [x] A first version of the site, **live at https://playgulibatto.vercel.app**: home, how to play, about, download (reads the real release), privacy, share image, theme toggle, and a play page that frames Godot's default page
- [x] The web export builds and plays in headless Chrome (menu, aim, a shot, a computer toss into the kep; no console errors)
- [x] Checks: lint, token and colour checks, file size, game and site tests, a smoke test, and CI that passes on `main`

## App plan (agreed 2026-10-22), in this order

1. [x] **Saved settings and reset:** theme, sound, volume, follow-shots, the first-use prompt and the rules cards seen are kept between runs (`Settings`); Settings has a confirmed "Reset to defaults"; 135 game tests
2. [x] **Shot-follow camera for every mode:** follow a shot while it rolls, ease back to the framed view, a "Follow shots" toggle in Settings, a tap skips it, Kep included (`CameraDirector`); 135 game tests
3. [x] **Sound:** synthesized sounds written by `scripts/sounds.mjs` (no downloads), played from physics events, shots, buttons and the end of a match; on/off and volume in Settings; 135 game tests. **Not yet listened to by a person**, and the web build's audio start on the first tap is not yet checked in a browser
4. [ ] **Guli Khela and Quick Dan** (Phase 5 below), on a Kep-scale round board
5. [ ] **Pages and per-game teaching** (Phase 6, the app half): one `content/` source, diagrams from data, a long How to play, a page per game, a rules card the first time each game starts and a "?" in the match, About, Contact, Privacy, links to the web version and the Android download
6. [ ] **Phone test, tuning and release** (Phase 7): play all four on a phone, tune pull, settle time and Batto's race length, check the rules with a player, publish

Open: the email or form for Contact.

## Phase 0 — Android and web build and run

- [x] CI and infra follow the sibling project's flow (Godot Docker image, `make game-docker-*`, an export target for each build, quality / web / game / build / release jobs, rolling `latest` plus versioned releases, the Vercel deploy hook, `docs/DEPLOY.md`). **It ran on `main` and published `v0.0.1`** with the APK, the web export and checksums (the desktop builds it also had are dropped)
- [x] Scope narrowed to Android and the web: the Windows, macOS and Linux builds, presets and Makefile targets are removed
- [x] Docker image run locally: the check, the tests and all five exports
- [x] First run of the pipeline on GitHub passed
- [x] Exclude the stray `gulibatto-debug.apk.idsig` from the release files (the build step removes it)
- [ ] Run each build on a real target: an Android phone and a desktop browser
- [x] Vercel project and the `VERCEL_DEPLOY_HOOK` secret
- [ ] Create the fixed Android key secret (`make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64`)
- [ ] Confirm the live sitemap and share image use the Vercel address after the next deploy (a fix is in this change)
- [ ] Check Jolt in the web export directly

## Phase 1 and 2 — hand checks

- [ ] Play it on a phone and with a few people: pull sensitivity, the 3 to 5 s settle time, how often the kep captures, orbit and pinch zoom

## Phase 4 — Batto

- [x] Three holes and the route on screen, hits and bonus shots (a hit or reaching a hole, cap of three), finishing order, computer sides choosing between the hole and a hit, cues, tests for every rule (87 game tests; full races with three computer sides take 34 to 78 shots)
- [ ] Hand check Batto on a phone: hole spacing, how often a hit lands (a full race with three computer sides is only 19 to 25 shots, about half of them bonus shots, so it may be too short), the length of a race
- [ ] Check the Batto rules with at least one more person who played

## Phase 5 — Guli Khela and Quick Dan

- [ ] Purses and stake, the scatter, naming the baad, a clean touch and a fine, winning a dan, the three-pass rule, surrender, the end; computer sides that name a baad and touch one marble; Quick Dan as a profile; tests for every rule
- [ ] Check the Guli Khela rules with at least one person who played

## Phase 6 — the pages, on the web and in the app

- [ ] `content/` source and the diagram format; a check that the game and the site match; move the About text onto it
- [ ] Site: the large Home, a page for each game, the very large How to play, Contact, About, Privacy
- [ ] App: How to play, mode info, About, Contact, Privacy, and the links to the web and to the Android download
- [ ] Site-native browser loader (progress, WebGL and WebAssembly checks, failure and retry, sharp sizing, fullscreen) replacing the framed Godot page
- [ ] Download page for the APK and the browser version, reading the release
- [ ] The basics: sound, locally saved settings with a reset
- [ ] Contact details to publish; the author's review of the How to play and games wording

## Phase 7 — release

- [ ] Automatic release of the APK, the web export and `SHA256SUMS` when the version changes
- [x] Site host chosen and deployed: Vercel, `playgulibatto.vercel.app`
- [ ] Hand-test on a phone and in a desktop browser; write the known-limitations note
- [ ] Check the rules with people who played; update the About page from what they said

## Open decisions

- [ ] A custom domain, if wanted
- [ ] Whether to add iOS or a store listing later (not planned)
