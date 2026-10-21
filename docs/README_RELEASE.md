# Releases and the marketing site

## Versioning

`VERSION` is the source of truth. `make version v=0.2.0` writes it into `VERSION`, `game/project.godot`, the Android preset and `web/package.json` (no git). `make release v=0.2.0` does the same, then commits and pushes; you run it, nothing runs it automatically. Both refuse the same or a lower version.

## What CI publishes

On a push to `main`, after the game and web checks pass, CI builds a debug APK and the browser export (`make apk`, `make web`) and publishes them:

- **Versioned release `vX.Y.Z`** when `VERSION` names a version with no release yet: APK, SHA-256 checksum and the web export tarball, with generated notes. This becomes the GitHub "latest" release.
- **Rolling `latest` build** on every main push: a dev channel that never takes the "latest" flag.

Each build gets a higher Android `version/code` (the CI run number), so a newer APK installs over an older one. For that to work the signing key must stay the same: set the repository secret `ANDROID_DEBUG_KEYSTORE_BASE64` (base64 of a debug keystore). Without it each build is signed with a throwaway key and cannot be installed over a previous one.

**Not yet verified:** the APK and web export jobs have never run. The first run on GitHub may need fixes (export templates path, Android SDK and JDK paths). Record what was needed here.

## Marketing site (`web/`)

A small Next.js site: home, how to play, download, privacy. It is for explaining and distributing the game, not for running it. It has no accounts, no database, no cookies and no trackers, and it needs no backend.

- The download page reads the latest GitHub release at build time and revalidates hourly, so it shows the newest APK and checksum. Set `GITHUB_REPOSITORY` (default `shahadathhs/GuliBatto`) if the repository differs.
- Copy must follow the rules in [README_GAME_RULES.md](README_GAME_RULES.md): Guli Khela is "adapted", Batto is "provisional", and nothing claims traditional authenticity.
- Hosting is undecided (any static or Node host works). If the site should embed a playable browser build later, the release already ships the web export.
- Run it with `pnpm --filter web dev`; CI runs `typecheck` and `build`.
