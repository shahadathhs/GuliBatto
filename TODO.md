# TODO

The plan and the reasons are in [docs/README_ROADMAP.md](docs/README_ROADMAP.md) and [docs/README_IMPLEMENTATION.md](docs/README_IMPLEMENTATION.md). Tick items as they are done.

## Done: repository scaffold

- [x] Docs: architecture and code standards
- [x] Doc fixes: roadmap and implementation mapping, Guli Khela score attack before the AI, pit definition
- [x] `AGENTS.md`, `Makefile`, `.editorconfig`, `.gitignore`, `gdlintrc`
- [x] Godot 4.7 project in `game/` with the Compatibility renderer, GUT, and a smoke scene (camera, light, ground, one marble) with two passing tests (`make game-test`)
- [x] CI workflow (`.github/workflows/ci.yml`)

## Done: release pipeline and marketing site (not yet run on GitHub)

- [x] `VERSION`, `make version`, `make release`, version stamped into the Android preset in CI
- [x] CI workflow builds APK and web export on main and publishes a versioned release plus a rolling `latest` (written, never run)
- [x] `web/` marketing site: home, how to play, download (reads latest release), privacy; `typecheck` and `build` pass locally

## Pending: release and site

- [ ] Push to GitHub, run the workflow once, fix whatever the APK job needs; record it in `docs/README_RELEASE.md`
- [ ] Create the fixed debug keystore secret `ANDROID_DEBUG_KEYSTORE_BASE64`
- [ ] Choose site hosting and a domain; add screenshots once the game has art

## Now: Milestone 0, export smoke test

**Not done: nothing has been exported or run on a device or in a browser.** The scene loads and its tests pass headless on this machine only.

- [ ] Install Godot 4.7 export templates; pin the exact version in `project.godot`, the Makefile and CI
- [ ] Set up the Android SDK and a debug keystore in Godot's editor settings
- [ ] `make game-apk`, install on a real phone, confirm the scene runs and touch input arrives
- [ ] `make game-web`, serve `game/build/web/` locally, load in a current desktop browser, check the console is clean
- [ ] Record issues and the final export settings in `docs/README_IMPLEMENTATION.md`
- [ ] Decide the Android minimum SDK and target device tier; decide where the web build is hosted

## Next: Milestone 1, marble test bench

- [ ] `ShotCommand`, `SettleDetector` and `BoardSnapshot` in `game/scripts/core/` with GUT tests
- [ ] Test scene: flat ground, boundaries, two or three marbles, reset layout
- [ ] Shot applier, friction and bounce calibration, debug readout
- [ ] Test cases listed in the implementation plan (straight, head-on, glancing, wall, trapped, low and max power, rapid restart)
- [ ] Record tuned settle thresholds and tick rate in `docs/README_ARCHITECTURE.md`

## Open decisions

- [ ] Guli Khela pit: size, distance, and whether a success keeps the turn (needs the player research in `README_GAME_RULES.md`, section 7)
- [ ] Batto circle knockout: marbles per side, partly-outside rule, whether the striker can be knocked out
- [ ] UI language: English only, or English and Bangla (check Bangla font rendering in Godot first)
- [ ] Whether hot-seat is wanted before the AI (default: no, only if playtests ask)
- [ ] Release channel: Google Play, itch.io, or direct APK
