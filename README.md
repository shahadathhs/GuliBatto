# Guli & Batto

A small, tactile, offline 3D marble game inspired by Guli Khela and Batto. Godot 4, GDScript, Android first, desktop browser second. The name and the Batto rules are provisional; see [docs/README_GAME_RULES.md](docs/README_GAME_RULES.md).

**Status:** Milestone 0. A test scene loads and its tests pass headless. Nothing has been exported to a device or browser yet.

```sh
pnpm install # once: commit hooks
make run     # play (needs Godot 4.7)
make check   # load, lint, test (needs uv for gdtoolkit)
make help
```

`web/` is the marketing site (`pnpm --filter web dev`). Releases and versioning: [docs/README_RELEASE.md](docs/README_RELEASE.md).

Docs are in `docs/`; start with [README_PROJECT_OVERVIEW.md](docs/README_PROJECT_OVERVIEW.md). The checklist is [TODO.md](TODO.md).
