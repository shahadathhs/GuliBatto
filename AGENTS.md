# AGENTS.md

Instructions for AI coding agents working in this repository.

## Project

Guli & Batto (working title): a small offline 3D marble game inspired by Guli Khela and Batto. Godot 4, GDScript, Compatibility renderer, Android first, desktop browser second. The Godot project is in `game/`; `web/` is a small marketing site (Next.js) and holds no game logic. See `docs/README_RELEASE.md` for versioning and CI releases.

- `docs/` is the specification and the source of truth; read the relevant file before changing behaviour.
- Read `docs/README_PROJECT_OVERVIEW.md` for scope. Do not add anything from its "out of scope" list (online play, accounts, game backend, human avatars, monetisation).
- `docs/README_ARCHITECTURE.md` defines layers and where code goes; `docs/README_CODE_STANDARDS.md` defines style and the review checklist.
- Never claim you ran Godot, exported a build, or tested on a phone or in a browser unless you actually did. Say exactly which `make` targets you ran.

## Git

Work on `dev`; changes reach `main` through a pull request. Commits follow Conventional Commits (commitlint enforces it in the `commit-msg` hook; the `pre-commit` hook runs gdformat, gdlint and prettier on staged files). Run `pnpm install` once to install the hooks. Never skip hooks (`--no-verify`). Never commit secrets or signing keys. Do not commit or push unless the user asks.

## Commands

`make` is the command surface (run `make help`). CI runs the same targets.

```sh
make check    # load the project, lint, test (what CI runs)
make test     # GUT tests, headless
make lint     # gdlint + gdformat --check
make format   # gdformat
make run      # play on this machine
make version v=X.Y.Z  # write a version into every file that carries it (no git)
make apk      # debug APK (needs Android export templates and SDK)
make web      # browser export (needs Web export templates)
```

After any change run the targets that cover it. Docs in `docs/` must match the code; update them in the same change.

## Architecture rules (do not break)

- **One simulation, several views.** Camera mode changes presentation only. Nothing in `camera/` or `ui/` changes shot direction, power, physics, or score.
- **One shot path.** Player and AI both build a `ShotCommand` and submit it to the match. Only `physics/` applies impulses.
- **Physics is real.** Never fake motion with transform animation, and never hide weak physics under effects.
- **Rules read snapshots.** Scoring is decided once per shot, from a `BoardSnapshot` taken after the board settles. Collision callbacks are evidence, not scoring.
- **Content is data.** Layouts, sizes, limits and score values live in `RuleProfile` resources. No `if mode == ...` branches in UI or physics code.
- **Restart is atomic.** It builds a fresh match; it never reuses partial turn state.
- **Offline.** No network, accounts, analytics, or third-party SDKs.
- **Be honest about tradition.** Guli Khela is "adapted"; Batto is "provisional". Do not describe a rule as authentic unless README_GAME_RULES.md records a verified source.
- **Colors come from one theme resource.** A grep for hex colors or `Color(` outside the theme file must find nothing. (The Milestone 0 test scene is the only exception until the theme exists.)

## Code shape rules

- GDScript with static types on every variable, parameter and return value.
- Hand-written source files stay under 300 lines (450 is the ceiling).
- Extract shared helpers on the second copy; never paste between files.
- Any edit to an oversized file splits or extracts the part being touched; do not grow it.
- Every rule, state transition and settle condition has a GUT test; rule tests use hand-built snapshots.

## Work order

Follow `docs/README_IMPLEMENTATION.md`: build the riskiest slice first. Do not build menus, art, or the AI before the shot feels right. Track progress in `TODO.md`.

## Web

`web/` explains and distributes the game: home, how to play, download, privacy. No backend, accounts, cookies or trackers. Copy must keep the "adapted" and "provisional" labels for the rules. Run `pnpm --filter web typecheck` and `pnpm --filter web build` after changes.
