# Guli & Batto — Code Standards

> **Purpose:** the conventions every contributor (human or AI tool) follows, and the checklist a change must pass before merge. Structure is in [README_ARCHITECTURE.md](README_ARCHITECTURE.md).

## 1. Language and style

- **GDScript only.** C# is not used, because Godot cannot export C# projects to the web.
- Follow Godot's official GDScript style guide: `snake_case` for functions, variables and files, `PascalCase` for classes, `SCREAMING_CASE` for constants and enum values, tabs for indentation.
- **Static typing everywhere:** type every variable declaration, parameter and return value (`var power: float = 0.0`, `func evaluate(snapshot: BoardSnapshot) -> RuleResult:`). Untyped code is rejected in review.
- `class_name` for any script used by another script. One class per file; the file name is the snake_case of the class name.
- Signals are named in the past tense (`shot_committed`, `board_settled`). Callbacks are `_on_<source>_<signal>`.
- Format and lint with gdtoolkit (pinned in the Makefile): `make format`, `make lint`. The lint config is `gdlintrc`.

## 2. File and function size

- Hand-written files stay under **300 lines**. 450 lines is the review-reject ceiling.
- A function does one thing. If it needs a comment to separate its sections, split it.
- Any edit to an oversized file splits or extracts the part being touched; do not grow it.
- Extract a shared helper on the second copy. Never paste between files.

## 3. Rules that protect the design

These come from the architecture and must not be broken:

1. **Simulation first.** Physics is never faked with transform animation. Camera, UI and AI never apply impulses.
2. **One shot path.** Player and AI both create a `ShotCommand` and submit it to the match.
3. **Rules read snapshots.** Scoring code takes a `BoardSnapshot`, never live nodes, and never reacts to a collision callback directly.
4. **Evaluate once.** The evaluation step is guarded so a shot cannot score twice.
5. **Camera is presentation.** Nothing in `camera/` is read by `core`, `rules`, `match` or `physics`.
6. **Data in resources, decisions in scripts.** Layouts, sizes, limits and score values live in `RuleProfile` resources. There is no `if mode == ...` scattered across UI or physics scripts.
7. **No magic numbers.** Tuning values are named constants in one place or exported resource fields. A threshold that appears in a test must come from the same constant as the code.
8. **Offline.** No network calls, analytics, or third-party SDKs.
9. **Colours come only from `design/tokens.json`.** `make tokens` generates the Godot palette (`Palette.get_color`) and the web CSS variables. `make colors-check` fails on a hex value or `Color(...)` anywhere else, and `make tokens-check` fails when a generated file is out of date or a text pair loses contrast.

## 4. Tests

- Every rule, state transition and settle condition has a GUT test. A bug fix adds a test that fails before the fix.
- Rule tests use hand-built snapshots, so they are fast and do not depend on physics.
- Physics tests assert outcomes with margins, never exact floating-point positions.
- A test never depends on frame rate, wall-clock time, or the order of other tests.
- Tests that step real physics for a long time extend `PhysicsTest` (`tests/physics_test.gd`), which ignores one known, benign Jolt job-queue warning and nothing else.
- Run `make game-test` before saying a change works. State exactly what you ran. Do not claim an export, device run or browser run that did not happen.

## 5. Assets and licences

- Every audio file, font and texture has a recorded source and licence in a `LICENSE` or `SOURCES.md` beside it.
- No recordings of a real person's voice or a recognisable cultural performance without written permission.
- Keep textures small; budgets and fallbacks are in [README_VISUAL_DESIGN.md](README_VISUAL_DESIGN.md).

## 6. Git and review

- Work on `dev`; changes reach `main` through a pull request.
- Commits follow Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, ...).
- commitlint enforces this in the `commit-msg` hook; the `pre-commit` hook formats and lints staged files. Never skip hooks.
- Never commit secrets, signing keys, or `export_credentials.cfg`.
- Commit after each verified milestone, not after a large batch of untested generated code.
- Docs change in the same commit as the behaviour they describe.

## 7. Review checklist

- [ ] Types on every declaration; gdlint and gdformat pass.
- [ ] No file over 300 lines grew; none is over 450.
- [ ] Rules are in `rules/` and read a snapshot; UI contains no scoring.
- [ ] Shot goes through `ShotCommand`; no direct impulse outside `physics/`.
- [ ] Restart and rematch leave no stale state (turn, score, guard flags, aim preview).
- [ ] New tuning values are named, not inlined.
- [ ] Tests added or updated; `make game-test` output is quoted in the PR.
- [ ] Docs updated.
- [ ] Works with the low-cost visual setting; does not need Forward+ or Mobile renderer features.
