# CI, tooling and releases

> **Status: the gates pass locally; the workflow has not yet run on GitHub.** `make check` passes, and `actionlint` is clean. The APK, export and release jobs have never run, so treat the build and release parts as the design until the first run is recorded here. Update this file in the same change as any workflow or tooling change.

## Principles

- **One command surface.** The `Makefile` is how you run everything locally; CI runs the same targets, so "passes locally" means "passes in CI".
- **Gates before builds.** Pull requests and every push run the checks; only `main` builds and publishes.
- **Fail closed.** A missing optional secret produces a visible warning, never a silent skip of something critical.
- **Pinned and reproducible.** Lockfiles are frozen in CI, tool versions are pinned, and Dependabot keeps actions and dependencies current.

## Pipeline (`.github/workflows/ci.yml`)

One workflow, with a `concurrency` group per ref and least-privilege `permissions`. Godot is installed by a small composite action (`.github/actions/setup-godot`) that caches the binary and the export templates.

| Job         | Runs for          | What it does                                                                                                            |
| ----------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `quality`   | every push and PR | `make lint`: gdlint, gdformat, prettier, oxlint (type-aware), token drift and contrast, hand-written colours, file size |
| `game`      | every push and PR | Headless project load (`make game-check`) and the GUT tests (`make game-test`)                                          |
| `web`       | every push and PR | Type-check, unit tests, production build, and a smoke test of every built page                                          |
| `workflows` | every push and PR | `actionlint` on the workflow files, run from its container image                                                        |
| `export`    | pull requests     | `make apk` and `make web`, so a PR proves both exports still build; nothing is published                                |
| `build`     | `main`            | Resolves the version, stamps the Android version code, builds the debug APK and the web export, writes a SHA-256        |
| `release`   | `main`            | Refreshes the rolling **latest** build; publishes `vX.Y.Z` when `VERSION` names a version with no release               |

`make check` runs the same gates locally (all but `export`, which needs the Android SDK), so "passes locally" means "passes in CI".

### What each gate enforces

| Gate                     | Enforces                                                                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Token drift and contrast | `scripts/tokens.mjs --check`: the generated Godot palette and web CSS match `design/tokens.json`, and every text pair in its `contrast` list passes |
| Colour check             | `scripts/check-colors.mjs`: no hand-written colour outside the token source and generated files (the Milestone 0 scene is the one exception)        |
| File-size check          | `scripts/check-file-size.mjs`: files under 300 lines, 450 hard ceiling ([README_CODE_STANDARDS.md](README_CODE_STANDARDS.md))                       |
| oxlint (type-aware)      | Correctness in `web/` and `scripts/`; no ESLint, since TypeScript 7 has no JS compiler API                                                          |
| Web unit tests           | Parsing of the GitHub release data: valid, no checksum, no APK, non-https link, odd tag, garbage, zero size                                         |
| Web smoke test           | Every page answers 200 with its content in the HTML (so it works without JavaScript), sets no cookie, and loads nothing from another site           |
| `actionlint`             | The workflow files                                                                                                                                  |

### Not planned

- A check that the concept renders match the committed images. Regenerating them needs Google Chrome (`node scripts/design/render.mjs`), so it stays a manual step.

## Versions and releases

`VERSION` is the source of truth.

```sh
make version v=0.2.0    # write the version into VERSION, game/project.godot, the Android preset and web/package.json (no git)
make release v=0.2.0    # the same, then commit and push (you run this; nothing runs it automatically)
```

Both refuse the same or a lower version; `release` also refuses to run with uncommitted changes, so the release commit contains only the bump. When it reaches `main`, CI sees a `VERSION` with no matching release and publishes `vX.Y.Z` with the APK, its checksum and the web export tarball, marked as the latest release. Rolling builds keep flowing and never take the "latest" flag.

Each build gets a higher Android `version/code` (the CI run number), so a newer APK installs over an older one, provided it is signed with the **same key**.

## Secrets and variables

| Name                            | Kind                            | Used by                                                                                                            |
| ------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `ANDROID_DEBUG_KEYSTORE_BASE64` | secret                          | `build` (a fixed signing key, so builds install over each other)                                                   |
| `GITHUB_API_URL`                | web env, tests only             | the download page: point it at a stand-in server to see the page with a release (leave unset in production)        |
| `PLAY_BUILD_TAG`                | web env, optional               | the site's build (`scripts/fetch-play-build.mjs`): which release's browser export `/play` serves, default `latest` |
| `GITHUB_REPOSITORY`             | web env                         | the download page (default `shahadathhs/GuliBatto`)                                                                |
| `VERCEL_DEPLOY_HOOK`            | secret, optional, not wired yet | rebuild the site after a release so the download page shows it                                                     |

Without `ANDROID_DEBUG_KEYSTORE_BASE64` each build is signed with a throwaway key and cannot be installed over a previous one. Create the key once and store it as a secret; changing it changes the signing key. A store release needs a separate upload keystore and an `.aab`; that is outside the current scope. Secrets are never committed.

## Local tooling

| Tool                       | Purpose                                                                            |
| -------------------------- | ---------------------------------------------------------------------------------- |
| Husky                      | Git hooks (`pre-commit`, `commit-msg`)                                             |
| lint-staged                | Format and lint staged files only (`game/scripts`, `game/tests`, docs, JSON, YAML) |
| commitlint                 | Conventional Commits                                                               |
| commitizen + cz-git        | Guided commits (`pnpm commit`)                                                     |
| gdtoolkit (pinned, via uv) | `gdlint` and `gdformat`                                                            |
| GUT                        | Game unit tests, run headless                                                      |
| Prettier                   | Formatting for markdown, JSON, YAML                                                |
| oxlint                     | Type-aware lint of the site and scripts                                            |
| Next.js                    | The marketing site                                                                 |

Typical targets: `make check`, `make test`, `make lint`, `make format`, `make run`, `make apk`, `make web`, `make version v=X.Y.Z`.

## Branching and commits

Work on `dev`, open a pull request into `main`, and keep `dev` fast-forwarded to `main` after each merge. Commits follow Conventional Commits and are validated by the `commit-msg` hook. Never skip hooks.

## Known limits to revisit

- The Godot download URL, the export-template path and the Android SDK and JDK paths on the runner are unverified.
- Each run downloads Godot and the export templates; add caching if it becomes slow.
- Release builds are debug-signed APKs. A proper release keystore comes with a store listing.
- The first successful run on GitHub must be recorded here, with whatever had to change.
