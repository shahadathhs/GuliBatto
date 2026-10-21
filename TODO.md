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

- [ ] Push to GitHub, run the workflow once, fix whatever the APK job needs; record it in `docs/CI.md`
- [ ] Create the fixed debug keystore secret `ANDROID_DEBUG_KEYSTORE_BASE64`
- [ ] Choose site hosting and a domain; add screenshots once the game has art

## Done: tooling gaps from the comparison review

- [x] Web: oxlint (type-aware), unit tests for the release parsing, a smoke test of every page, robots and sitemap
- [x] `design/tokens.json` with generators for the Godot palette and web CSS, a token drift and contrast check, a colour-literal check; the site now uses the generated tokens
- [x] File-size check (300 soft, 450 hard)
- [x] CI: quality, game, web, actionlint, export on pull requests, Godot and template caching
- [x] `make check` runs every gate locally except the exports

## Pending: web and CI

**Not verified on GitHub:** the workflow has never run there. The first run may need fixes (export templates, Android SDK and JDK paths); record them in `docs/CI.md`.

- [ ] Web: light/dark toggle (progressive enhancement), Open Graph image, accessibility and contrast pass against `docs/design/web/`
- [ ] Confirm the orientation (portrait proposed) and the UI language (Bangla or not) from playtests

## Now: Milestone 0, export smoke test

**Not done: nothing has been exported or run on a device or in a browser.** The scene loads and its tests pass headless on this machine only.

- [ ] Install Godot 4.7 export templates; pin the exact version in `project.godot`, the Makefile and CI
- [ ] Set up the Android SDK and a debug keystore in Godot's editor settings
- [ ] `make game-apk`, install on a real phone, confirm the scene runs and touch input arrives
- [ ] `make game-web`, serve `game/build/web/` locally, load in a current desktop browser, check the console is clean
- [ ] Record issues and the final export settings in `docs/README_IMPLEMENTATION.md`
- [ ] Decide the Android minimum SDK and target device tier; decide where the web build is hosted

## Built: a playable Kep match (Milestones 1 to 3 in part)

Press Play, choose Kep, drag back from your marble and release. You play three sides (you and two computer sides) over five rounds. `make run` to try it; `make check` for the gates (62 game tests).

- [x] Core: `ShotCommand`, `ShotReport`, `BoardSnapshot`, `SettleDetector`, `RuleProfile`, `GroundField`, `Tuning`
- [x] Physics: `Board`, `Marble` (with side marks), `Arena` with a real dish at the kep (Jolt physics, heightmap ground), `ShotApplier`
- [x] Rules: `KepRules` scoring (in the kep 3, closest 2, next 1, ties share) and `MatchController` (turns, rounds, worst-first order, round result, match over); `TossAI` (about half its tosses land in the kep)
- [x] Input: drag-to-aim (slingshot, world-space, dead zone, cancel), orbit, wheel and pinch zoom; tested through the real input path
- [x] Camera: `CameraRig` with angled, top-down and low views, reset, elevation and zoom limits
- [x] UI as in the concept renders: menu, mode select, About, How to play, Settings (theme), HUD with the power meter and first-use prompt, round result, match over, pause; light and dark
- [ ] **Played by hand on a phone:** nothing here has been played on a device. Feel (pull sensitivity, settle time of 3 to 5 s, how often the kep captures) needs a human
- [ ] Shot-follow camera, sound, saved settings, Bangla text, UI polish against the renders at 360 × 640 and 412 × 915
- [ ] Milestone 0 is still open: nothing has been exported to a device or browser (this machine has no Android export templates). Jolt's support in the web export is unverified

## Next

- [ ] Batto (three holes, route, hits, bonus shots), then Guli Khela (stake, scatter, baad, fines)
- [ ] Hot-seat is not built; the match is you against computer sides

## Open decisions

- [ ] Check the rules with at least one more person who played each game ("To confirm with players" in `docs/README_GAME_RULES.md`)
- [ ] Review the About page wording (`docs/README_ABOUT.md`) and keep `web/src/app/about/page.tsx` identical
- [ ] UI language: English only, or English and Bangla (check Bangla font rendering in Godot first)
- [ ] Whether hot-seat is wanted before the AI (default: no, only if playtests ask)
- [ ] Release channel: Google Play, itch.io, or direct APK
