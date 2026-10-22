# AGENTS.md

Instructions for AI coding agents working in this repository.

## Project

Guli & Batto (working title): a 3D marble game of four modes (Kep, Batto, Guli Khela, Quick Dan), each a modernised version of a traditional marble game the author played as a child. One Godot 4 project (GDScript, Compatibility renderer, Jolt physics) exports to Android and the web; the web version is the full game, not a try-out. `web/` is the website (Next.js) and holds no game logic. The site and the app show the same pages from one source of content. The scope is the four modes represented properly and nothing extra (see the overview's "Not in" list). See `docs/CI.md` for versioning and releases.

- `docs/` is the specification and the source of truth; read the relevant file before changing behaviour.
- Read `docs/README_PROJECT_OVERVIEW.md` for scope. Do not add anything from its "out of scope" list (online play, accounts, game backend, human avatars, monetisation).
- `docs/README_ARCHITECTURE.md` defines layers and where code goes; `docs/README_CODE_STANDARDS.md` defines style and the review checklist.
- Never claim you ran Godot, exported a build, or tested on a phone or in a browser unless you actually did. Say exactly which `make` targets you ran.

## Git

Work on `dev`; changes reach `main` through a pull request. Commits follow Conventional Commits (commitlint enforces it in the `commit-msg` hook; the `pre-commit` hook runs gdformat, gdlint and prettier on staged files). Run `pnpm install` once to install the hooks. Never skip hooks (`--no-verify`). Never commit secrets or signing keys. Do not commit or push unless the user asks.

## Commands

`make` is the command surface (run `make help`). CI runs the same targets.

```sh
make check         # every gate CI runs, except the exports (needs uv, pnpm, Godot)
make lint          # gdlint, gdformat, prettier, oxlint, tokens, colours, file size
make test          # GUT tests and the site's unit tests
make format        # gdformat and prettier
make tokens        # regenerate the Godot palette and web CSS from design/tokens.json
make sounds        # regenerate the sound effects in game/audio from scripts/sounds.mjs
make content       # regenerate game/data/content.json from content/
make run           # play on this machine
make web-dev       # the website at localhost:3000
make game-docker-check   # load the project in the Godot container (what CI runs)
make game-docker-test    # the game tests in the container
make game-apk | game-web   # exports, in the container
make workflows           # lint the GitHub workflow files
make version v=X.Y.Z  # write a version into every file that carries it (no git)
```

After any change run the targets that cover it. Docs in `docs/` must match the code; update them in the same change.

## Architecture rules (do not break)

- **One simulation, several views.** Camera mode changes presentation only. Nothing in `camera/` or `ui/` changes shot direction, power, physics, or score.
- **One shot path.** Player and AI both build a `ShotCommand` and submit it to the match. Only `physics/` applies impulses.
- **Physics is real.** Never fake motion with transform animation, and never hide weak physics under effects.
- **Rules read snapshots and the shot report.** Scoring is decided once per shot, from a `BoardSnapshot` taken after the board settles. Collision callbacks are evidence, not scoring.
- **Content is data.** Layouts, sizes, limits and score values live in `RuleProfile` resources. No `if mode == ...` branches in UI or physics code.
- **Restart is atomic.** It builds a fresh match; it never reuses partial turn state.
- **Offline.** No network, accounts, analytics, or third-party SDKs.
- **Honesty lives on the About page.** `docs/README_ABOUT.md` says where the rules come from and what the author changed. Mode screens, the HUD, the site and store text carry no per-mode labels ("adapted", "provisional", "traditional", "authentic") and never call a rule official. When a rule changes, update the About page's "What I changed" list in the same change. Nothing is invented from nothing: each mode comes from a game in `docs/README_GAME_RULES.md`, section 1.
- **Colours come only from `design/tokens.json`.** `make tokens` generates the Godot palette and web CSS; `make colors-check` fails on any hex value or `Color(...)` elsewhere. The Milestone 0 smoke scene is the one exception until the real arena exists.

## Code shape rules

- GDScript with static types on every variable, parameter and return value.
- Hand-written source files stay under 300 lines (450 is the ceiling).
- Extract shared helpers on the second copy; never paste between files.
- Any edit to an oversized file splits or extracts the part being touched; do not grow it.
- Every rule, state transition and settle condition has a GUT test; rule tests use hand-built snapshots.

## Work order

Follow `docs/README_IMPLEMENTATION.md`: build the riskiest slice first. Do not build menus, art, or the AI before the shot feels right. Track progress in `TODO.md`.

## Web and app pages

`web/` teaches and distributes the game: Home, the four game pages, How to play, Play, Download, About, Contact, Privacy. The app carries the same information. Both render the shared `content/` and must not drift apart: `content/` holds the pages, rules cards, diagrams and links as data, `make content` writes `game/data/content.json` from it, and `make content-check` (part of `make lint`) fails when that file is stale, a link or diagram is broken, a mode page uses a history label, or About differs from `docs/README_ABOUT.md`. The site renders the same `content/` (copied to `web/src/lib/content.generated.json` by `make content`) through `Blocks` and `Diagram` in `web/src/components/`; only the Home, Download and Play pages hold their own words. No backend, accounts, cookies or trackers. Copy follows `docs/README_ABOUT.md`. Run `make check` after changes; see `docs/README_WEB_AND_APP_PLAN.md`.

## Visual rules (the house style: Drawn Ground)

Full rules are in `docs/README_VISUAL_DESIGN.md`. When touching UI or the site:

- Exactly one primary action per screen: a solid glaze-blue disc (a rounded rectangle when the label is longer than six letters, and a full-round button on the web). Secondary actions are outlined rounded rectangles; tertiary are underlined text.
- No gradients, glow, drop shadows, glass or blur in the UI; no card inside a card; no taglines, exclamation marks, emoji or folk-motif decoration.
- Marbles carry colour **and** a mark: player = blue ring, opponent = amber dot, neutral target = bone bar (a fifth side, rose with a diamond, exists for pass and play with five people). Colour is never the only signal.
- Both themes (light and dark) are first-class; check every screen in both. Colours come only from the token table, never hand-written.
- Concept renders live in `docs/design/` and are regenerated with `node scripts/design/render.mjs`.
