# TODO

The goal is the four modes, represented properly, on five platforms, with the same pages on the web and in the app, and nothing extra. The plan is in [docs/README_PROJECT_OVERVIEW.md](docs/README_PROJECT_OVERVIEW.md) and [docs/README_ROADMAP.md](docs/README_ROADMAP.md); the build order is in [docs/README_IMPLEMENTATION.md](docs/README_IMPLEMENTATION.md). Tick items as they are done.

**Replanned 2026-10-21.** The docs describe the new plan. The code and the CI workflow still reflect the older, smaller plan until the phases below are done.

## Built so far

- [x] The shot, settling and physics core with tests (Phase 1) and camera and input (Phase 2); checked headless and in rendered frames, **not played by hand on a phone**
- [x] Kep, complete as a playable mode against two computer sides, with the full screen set in light and dark (Phase 3); 62 game tests
- [x] A first version of the site: home, how to play, about, download, privacy, share image, theme toggle, and a play page that frames Godot's default page
- [x] The web export builds and plays in headless Chrome (menu, aim, a shot, a computer toss into the kep; no console errors)
- [x] Checks: lint, token and colour checks, file size, site tests and smoke test, CI that passes (build and release jobs have never run)

## Phase 0 — five platforms build and run

- [x] CI and infra follow the sibling project's flow: the Godot Docker image (`docker/`, `compose.yaml`), `make game-docker-*` and one export target per platform, quality / web / game / build / release jobs, rolling `latest` plus versioned releases, the Vercel deploy hook, and `docs/DEPLOY.md` (rewritten, **not yet run on GitHub**)
- [x] Export presets for Windows, macOS and Linux (Android and Web existed)
- [ ] Run the Docker image locally: `make game-docker-check`, `make game-docker-test`, and each export; confirm the image tag exists and has all five templates
- [ ] First run of the pipeline on GitHub; fix whatever it needs
- [ ] Run each build on a real target: an Android phone, a desktop browser, Windows, macOS, Linux
- [ ] Write down what an unsigned Windows and macOS build makes the OS say, for the download page
- [ ] Set up Vercel and the `VERCEL_DEPLOY_HOOK` secret; create the fixed Android key secret
- [ ] Check Jolt in the web export directly

## Phase 1 and 2 — hand checks

- [ ] Play it on a phone and with a few people: pull sensitivity, the 3 to 5 s settle time, how often the kep captures, orbit and pinch zoom

## Phase 4 — Batto

- [ ] Three holes and the route on screen, hits and bonus shots (a hit or reaching a hole, cap of three), finishing order, computer sides choosing between the hole and a hit, cues, tests for every rule
- [ ] Check the Batto rules with at least one more person who played

## Phase 5 — Guli Khela and Quick Dan

- [ ] Purses and stake, the scatter, naming the baad, a clean touch and a fine, winning a dan, the three-pass rule, surrender, the end; computer sides that name a baad and touch one marble; Quick Dan as a profile; tests for every rule
- [ ] Check the Guli Khela rules with at least one person who played

## Phase 6 — the pages, on the web and in the app

- [ ] `content/` source and the diagram format; a check that the game and the site match; move the About text onto it
- [ ] Site: the large Home, a page for each game, the very large How to play, Contact, About, Privacy
- [ ] App: How to play, mode info, About, Contact, Privacy, and the links to the web and to the other platforms
- [ ] Site-native browser loader (progress, WebGL and WebAssembly checks, failure and retry, sharp sizing, fullscreen) replacing the framed Godot page
- [ ] Download page for every platform, reading the release
- [ ] The basics: sound, locally saved settings with a reset
- [ ] Contact details to publish; the author's review of the How to play and games wording

## Phase 7 — release

- [ ] Automatic release of every platform file and `SHA256SUMS` when the version changes
- [ ] Choose the site host and a domain; deploy
- [ ] Hand-test every platform; write the known-limitations note
- [ ] Check the rules with people who played; update the About page from what they said

## Open decisions

- [ ] Site hosting and domain
- [ ] Desktop signing, if the warnings put people off
- [ ] Whether to add iOS or a store listing later (not planned)
