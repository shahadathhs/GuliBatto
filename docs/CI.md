# CI, tooling and releases

> **Status: this is the plan; the workflow in `.github/workflows/ci.yml` is the older, heavier design and is replaced in Phase 0 ([`README_ROADMAP.md`](README_ROADMAP.md)).** The old workflow passes its checks on GitHub, but its build and release jobs have never run, and it is more complicated than the job needs (a hand-written action that installs Godot, its templates and Android tooling; a rolling "latest" release; an extra export job on pull requests; a separate workflow-lint job). The design below replaces it. Update this file in the same change as any workflow or tooling change.

## Principles

- **One command surface.** The `Makefile` is how you run everything locally. CI runs the same targets, so "passes locally" means "passes in CI".
- **As few moving parts as work.** Four job definitions, no custom actions, no scripts that only reproduce a container.
- **Gates before builds, builds before releases.** Only a version change publishes.
- **Fail closed.** A missing platform file fails the release rather than publishing a partial one.
- **Pinned and reproducible.** Lockfiles are frozen, the Godot image is pinned, and Dependabot keeps actions and dependencies current.

## Pipeline

One workflow, `.github/workflows/ci.yml`, with a `concurrency` group per ref and least-privilege `permissions`.

| Job          | Runs for                                                    | What it does                                                                                                                                        |
| ------------ | ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `check-game` | every push and PR                                           | In the Godot container: load the project, `gdlint`, `gdformat --check`, and the GUT tests                                                           |
| `check-web`  | every push and PR                                           | On a plain runner: install, `make lint` (prettier, oxlint, tokens, colours, file size), type-check, unit tests, build, smoke test                   |
| `build`      | every push and PR; one run per platform                     | In the Godot container: export Android, Web, Windows, macOS and Linux, and upload each as an artifact. A pull request only proves the exports build |
| `release`    | `main`, only when `VERSION` names a version with no release | Download the artifacts, write `SHA256SUMS`, and publish release `vX.Y.Z` with every file, marked latest                                             |

**The Godot container** is the `barichello/godot-ci` image pinned to the project's Godot version. It already contains Godot, the export templates for every platform and the Android SDK, so no job installs or caches them by hand, and the same image can run `make` targets locally. The one extra step is a debug signing key for Android: generate it, or decode the repository secret if one is set so every build is signed the same way.

**No rolling build.** A release exists only for a version. The site fetches the web export from the latest versioned release. Before the first release, the site says the browser version is unavailable.

**Workflow lint** (`actionlint`) is a local target, `make workflows`, run before changing a workflow, not a CI job.

### What each gate enforces

| Gate                     | Enforces                                                                                                                                             |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Token drift and contrast | `scripts/tokens.mjs --check`: the generated Godot palette and web CSS match `design/tokens.json`, and every text pair in its `contrast` list passes  |
| Colour check             | `scripts/check-colors.mjs`: no hand-written colour outside the token source and generated files                                                      |
| File-size check          | `scripts/check-file-size.mjs`: files under 300 lines, 450 hard ceiling ([README_CODE_STANDARDS.md](README_CODE_STANDARDS.md))                        |
| oxlint (type-aware)      | Correctness in `web/` and `scripts/`; no ESLint, since TypeScript 7 has no JS compiler API                                                           |
| Content check (planned)  | The wording and diagrams in the game and on the site come from the same `content/` source ([README_WEB_AND_APP_PLAN.md](README_WEB_AND_APP_PLAN.md)) |
| Web unit tests           | Parsing of release data and checksums: valid, missing platforms, non-https link, odd tag, garbage                                                    |
| Web smoke test           | Every page answers 200 with its content in the HTML, sets no cookie, and loads nothing from another site                                             |
| Game tests               | Rules on hand-built boards, the physics outcomes, a full match through the real physics, and real input through the whole stack                      |

## Releases

`VERSION` is the source of truth.

```sh
make version v=0.2.0    # write the version into VERSION, game/project.godot, the export presets and web/package.json (no git)
make release v=0.2.0    # the same, then commit and push (you run this; nothing runs it automatically)
```

Both refuse the same or a lower version; `release` also refuses to run with uncommitted changes, so the release commit contains only the bump. When it reaches `main`, CI builds every platform and publishes `vX.Y.Z`.

| Platform  | File                           | Notes                                                                                                                                       |
| --------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Android   | `gulibatto-X.Y.Z.apk`          | A debug-signed APK; the version code is the CI run number so a newer build installs over an older one, provided the signing key is the same |
| Windows   | `gulibatto-X.Y.Z-windows.zip`  | Unsigned; Windows SmartScreen warns                                                                                                         |
| macOS     | `gulibatto-X.Y.Z-macos.zip`    | Unsigned; the first open needs right-click and Open                                                                                         |
| Linux     | `gulibatto-X.Y.Z-linux.tar.gz` | x86-64                                                                                                                                      |
| Web       | `gulibatto-X.Y.Z-web.tar.gz`   | The export the site serves at `/play`                                                                                                       |
| Checksums | `SHA256SUMS`                   | One line per file above                                                                                                                     |

The release job fails if any of the five files is missing. The site's download page reads these names ([README_WEB_AND_APP_PLAN.md](README_WEB_AND_APP_PLAN.md)).

## Secrets and variables

| Name                            | Kind                          | Used by                                                                                                                                 |
| ------------------------------- | ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `ANDROID_DEBUG_KEYSTORE_BASE64` | secret, optional              | `build` (a fixed Android signing key; without it each build is signed with a throwaway key and cannot be installed over a previous one) |
| `GITHUB_REPOSITORY`             | web env                       | the site's download page and `/play` fetch (default `shahadathhs/GuliBatto`)                                                            |
| `GITHUB_API_URL`                | web env, tests only           | point the site at a stand-in server to see a release without publishing one; leave unset in production                                  |
| `PLAY_BUILD_TAG`                | web env, optional             | which release's web export `/play` serves (default: the latest versioned release)                                                       |
| site rebuild hook               | secret, when a host is chosen | rebuild the site after a release so it shows the new files                                                                              |

Secrets are never committed. A store release would need an upload key and an app bundle; stores are not planned. Desktop code signing is not planned either.

## Local tooling

| Tool                            | Purpose                                              |
| ------------------------------- | ---------------------------------------------------- |
| Husky                           | Git hooks (`pre-commit`, `commit-msg`)               |
| lint-staged                     | Format and lint staged files only                    |
| commitlint, commitizen + cz-git | Conventional Commits, guided commits (`pnpm commit`) |
| gdtoolkit (pinned, via uv)      | `gdlint` and `gdformat`                              |
| GUT                             | Game unit tests, run headless                        |
| Prettier, oxlint                | Formatting and type-aware lint                       |
| Next.js                         | The website                                          |

Typical targets: `make check`, `make test`, `make lint`, `make format`, `make run`, `make web-dev`, `make web-play`, `make workflows`, `make version v=X.Y.Z`. The per-platform export targets move into the Godot container or the CI job in Phase 0.

## Branching and commits

Work on `dev`, open a pull request into `main`, and keep `dev` fast-forwarded to `main` after each merge. Commits follow Conventional Commits and are validated by the `commit-msg` hook. Never skip hooks.

## Known limits to check in Phase 0

- Confirm the `barichello/godot-ci` image exists for the pinned Godot version and contains all five templates.
- Exporting macOS from Linux gives an unsigned `.app`; confirm what a Mac says when it is opened and write it on the download page.
- A Windows export from Linux may keep the default icon unless an icon tool is available; confirm.
- Each platform build has to be run by a person before it is called working; CI only proves it builds.
- Whether the web export's physics uses Jolt in the browser was not checked directly; the physics behaves correctly there.
