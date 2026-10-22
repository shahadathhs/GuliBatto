# CI, tooling and releases

> **Status: ran on GitHub and passed (again on 2026-10-22, when the merge of PR #4 republished `v0.0.1` with all four games).** On 2026-10-21 the pipeline ran on `main` after pull request #2 and every job succeeded: quality, web, game (in the Docker image), build, and release. It published `v0.0.1` and a rolling `latest` with the APK, the web export, the desktop builds (since dropped) and checksums. The site rebuild hook (`VERCEL_DEPLOY_HOOK`) was added after that run, so its first real use is the next release. Update this file in the same change as any workflow or tooling change.

## Principles

- **One command surface.** The `Makefile` is how you run everything locally. CI runs the same targets, so "passes locally" means "passes in CI".
- **Gates before builds.** Pull requests and every push run the quality gates. Only `main` and version tags continue into build and release.
- **Fail closed.** A missing optional secret produces a visible warning, never a silent skip of something critical.
- **Pinned and reproducible.** Lockfiles are frozen in CI, tool versions are pinned, and Dependabot keeps actions and dependencies current.

## Pipeline

One workflow, `.github/workflows/ci.yml`, with `concurrency` per ref and least-privilege `permissions`.

| Job       | Runs for             | What it does                                                                                                                                                               |
| --------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `quality` | every push and PR    | Token drift and contrast, hand-written colours, file size, prettier and oxlint (`make lint`)                                                                               |
| `web`     | every push and PR    | Type-check, unit tests, production build and a smoke test of every page                                                                                                    |
| `game`    | every push and PR    | `gdlint` and `gdformat --check`, then headless Godot **in Docker** loads the project and runs the GUT tests                                                                |
| `build`   | `main` and `v*` tags | Resolves the version, stamps it, builds the APK and the web export in the Godot container, names the files and writes the checksums                                        |
| `release` | `main` and `v*` tags | Refreshes the rolling **latest** build, triggers the site rebuild (Vercel deploy hook), and publishes a versioned release when `VERSION` names a version without a release |

A normal push to `main`: the gates, the builds, the rolling latest build, the site rebuild. A version bump does all of that plus the versioned release. Pull requests run only the gates; the exports are built when something reaches `main`.

### The Godot image

`docker/godot.Dockerfile` is the `barichello/godot-ci` image pinned to the project's Godot version, which already contains Godot, the export templates and the Android SDK, plus `fontconfig` (which Godot loads at startup) and `zip`. `compose.yaml` defines it as the `godot` service in the `tools` profile and mounts `game/`. `docker/android-setup.sh` creates the Android debug key and points Godot's editor settings at the SDK and JDK; `docker/entrypoint.sh` starts `adb` quietly so exports do not print daemon warnings. The same image runs locally, so a local export matches CI.

### What each gate enforces

| Gate                     | Enforces                                                                                                                                             |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Token drift and contrast | `scripts/tokens.mjs --check`: the generated Godot palette and web CSS match `design/tokens.json`, and every text pair in its `contrast` list passes  |
| Colour check             | `scripts/check-colors.mjs`: no hand-written colour outside the token source and generated files                                                      |
| File-size check          | `scripts/check-file-size.mjs`: files under 300 lines, 450 hard ceiling ([README_CODE_STANDARDS.md](README_CODE_STANDARDS.md))                        |
| oxlint (type-aware)      | Correctness in `web/` and `scripts/`; no ESLint, since TypeScript 7 has no JS compiler API                                                           |
| gdlint and gdformat      | GDScript style in `game/scripts` and `game/tests`                                                                                                    |
| Game tests               | Rules on hand-built boards, physics outcomes, a full match through the real physics, and real input through the whole stack                          |
| Web unit tests           | Parsing of release data and checksums: valid, no checksum, no APK, non-https link, odd tag, garbage                                                  |
| Web smoke test           | Every page answers 200 with its content in the HTML, sets no cookie, and loads nothing from another site                                             |
| Content check (planned)  | The wording and diagrams in the game and on the site come from the same `content/` source ([README_WEB_AND_APP_PLAN.md](README_WEB_AND_APP_PLAN.md)) |

`make workflows` runs `actionlint` on the workflow files (in a container); run it before changing a workflow.

## Versions and releases

`VERSION` is the source of truth. Two make targets use `scripts/bump-version.sh`:

```sh
make version v=0.2.0    # write the version into VERSION, game/project.godot, the Android preset and web/package.json (no git)
make release v=0.2.0    # the same, then commit and push (you run this; nothing runs it automatically)
```

Both refuse the same or a lower version. `release` also refuses to run with uncommitted changes, so the release commit contains only the bump. When it reaches `main`, the pipeline sees a `VERSION` with no matching release and publishes `vX.Y.Z`. Rolling builds keep flowing and never take the "latest" flag.

| Platform  | File                                    | Notes                                                                                                                            |
| --------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Android   | `gulibatto-X.Y.Z.apk` and `.apk.sha256` | Debug-signed; the version code is the CI run number so a newer build installs over an older one when the signing key is the same |
| Web       | `gulibatto-web-X.Y.Z.tar.gz`            | The export the site serves at `/play`                                                                                            |
| Checksums | `SHA256SUMS`                            | One line for each file                                                                                                           |

Rolling builds use `X.Y.Z-<commit>` in the names. The build job fails if any platform file is missing, so a partial release is never published.

## Secrets and variables

| Name                                              | Kind                | Used by                                                                                                |
| ------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------ |
| `VERCEL_DEPLOY_HOOK`                              | secret, optional    | `release` (rebuild the site so the download page and `/play` show the new release)                     |
| `ANDROID_DEBUG_KEYSTORE_BASE64`                   | secret, optional    | `build` (a fixed signing key so builds install over each other)                                        |
| `SITE_URL`, `GITHUB_REPOSITORY`, `PLAY_BUILD_TAG` | Vercel environment  | the site's build; see [DEPLOY.md](DEPLOY.md)                                                           |
| `GITHUB_API_URL`                                  | web env, tests only | point the site at a stand-in server to see a release without publishing one; leave unset in production |

Create the signing key with `make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64`: the target prints only the key on stdout, so the pipe is clean. The `build` job checks the secret before the long build and fails with a clear message if it is not a valid keystore. Changing the secret changes the signing key. Secrets are never committed. Store uploads are not part of this pipeline.

## Local tooling

| Tool                            | Purpose                                              |
| ------------------------------- | ---------------------------------------------------- |
| Husky                           | Git hooks (`pre-commit`, `commit-msg`)               |
| lint-staged                     | Format and lint staged files only                    |
| commitlint, commitizen + cz-git | Conventional Commits, guided commits (`pnpm commit`) |
| gdtoolkit (pinned, via uv)      | `gdlint` and `gdformat`                              |
| GUT                             | Game unit tests, run headless                        |
| Prettier, oxlint                | Formatting and type-aware lint                       |
| Docker                          | The Godot image for checks and every export          |
| Next.js                         | The website                                          |

Typical targets: `make check`, `make lint`, `make game-lint`, `make test`, `make run`, `make game-docker-check`, `make game-docker-test`, `make game-apk`, `make game-web`, `make web-dev`, `make workflows`, `make version v=X.Y.Z`.

## Branching and commits

Work on `dev`, open a pull request into `main`, and keep `dev` fast-forwarded to `main` after each merge. Commits follow Conventional Commits and are validated by the `commit-msg` hook. Never skip hooks.

## Dependency updates

Dependabot runs weekly for GitHub Actions and the pnpm workspace, with action bumps grouped into one pull request.

## Known limits to revisit

- The Android APK is signed with a throwaway key until `ANDROID_DEBUG_KEYSTORE_BASE64` is set, so a later build cannot be installed over this one.
- CI proves each build exports; a person has to run each one. Only the web export has been run (in a headless browser); the APK has not been run on a real device.
- Whether the web export's physics uses Jolt in the browser was not checked directly; the physics behaves correctly there.
- Each run pulls the Godot image; add caching if it becomes slow.
