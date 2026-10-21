# Guli & Batto

A small, tactile, offline 3D marble game made from the traditional marble games of Bangladesh: Kep, Batto, Guli Khela and Quick Dan. The author remembered and modified the rules for the phone; see [docs/README_ABOUT.md](docs/README_ABOUT.md).

**Status:** Kep is playable, with the full UI in light and dark. Batto, Guli Khela and Quick Dan, the shared pages for the site and the app, and builds for every platform are next ([docs/README_ROADMAP.md](docs/README_ROADMAP.md)). Tested headless and in rendered frames; not yet played on a phone, and only the web export has been built so far.

```sh
make setup   # once: hooks, lint tooling, Godot cache
make run     # play (needs Godot 4.7)
make check   # every gate CI runs: lint, tokens, colours, tests, site build and smoke test
make help
```

`web/` is the website (`pnpm --filter web dev`). Releases and versioning: [docs/CI.md](docs/CI.md).

Docs are in `docs/`; start with [README_PROJECT_OVERVIEW.md](docs/README_PROJECT_OVERVIEW.md). The checklist is [TODO.md](TODO.md).
