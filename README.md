# Guli & Batto

A small, tactile, offline 3D marble game made from the traditional marble games of Bangladesh: Kep, Batto, Guli Khela and Quick Dan. The author remembered and modified the rules for the phone; see [docs/README_ABOUT.md](docs/README_ABOUT.md).

**Status:** Milestone 0. A test scene loads and its tests pass headless. Nothing has been exported to a device or browser yet.

```sh
make setup   # once: hooks, lint tooling, Godot cache
make run     # play (needs Godot 4.7)
make check   # every gate CI runs: lint, tokens, colours, tests, site build and smoke test
make help
```

`web/` is the marketing site (`pnpm --filter web dev`). Releases and versioning: [docs/CI.md](docs/CI.md).

Docs are in `docs/`; start with [README_PROJECT_OVERVIEW.md](docs/README_PROJECT_OVERVIEW.md). The checklist is [TODO.md](TODO.md).
