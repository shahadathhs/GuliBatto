# Command surface. CI runs the same targets.
GODOT     := godot
GAME      := game
GDTOOLKIT := gdtoolkit==4.5.0
GDLINT    := uvx --from $(GDTOOLKIT) gdlint
GDFORMAT  := uvx --from $(GDTOOLKIT) gdformat
GDPATHS   := $(GAME)/scripts $(GAME)/tests

.DEFAULT_GOAL := help
.PHONY: help setup import check lint format test game-check game-test tokens tokens-check colors-check size-check \
        web-lint web-typecheck web-test web-build web-smoke web-dev run apk web version release

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

setup: ## One-time: install Node tooling (hooks, lint) and build the Godot cache
	pnpm install
	$(MAKE) import

import: ## Import assets and build the Godot cache
	$(GODOT) --headless --path $(GAME) --import

# ── Everything CI checks ──────────────────────────────────────────────

check: lint game-check test web-typecheck web-build web-smoke ## Everything CI runs

lint: tokens-check colors-check size-check ## All style gates: gdlint, gdformat, prettier, oxlint, tokens, colours, file size
	$(GDLINT) $(GDPATHS)
	$(GDFORMAT) --check $(GDPATHS)
	pnpm exec prettier --check .
	$(MAKE) web-lint

format: ## Fix style in place (gdformat, prettier)
	$(GDFORMAT) $(GDPATHS)
	pnpm exec prettier --write .

test: game-test web-test ## All tests

# ── Rules that the docs state, enforced ───────────────────────────────

tokens: ## Regenerate the Godot palette and web CSS from design/tokens.json
	node scripts/tokens.mjs

tokens-check: ## Fail if generated colours are out of date or a contrast pair fails
	node scripts/tokens.mjs --check

colors-check: ## Fail if a colour is written by hand outside the token source
	node scripts/check-colors.mjs

size-check: ## Fail if a source file is over 450 lines (lists files over 300)
	node scripts/check-file-size.mjs

# ── Game ──────────────────────────────────────────────────────────────

game-check: import ## Load the project headless; fails on parse or script errors
	$(GODOT) --headless --path $(GAME) --quit-after 1

game-test: import ## Run the game tests (GUT)
	$(GODOT) --headless --path $(GAME) -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

run: ## Play on this machine
	$(GODOT) --path $(GAME)

apk: import ## Debug APK to game/build/ (needs Android export templates and SDK)
	@mkdir -p $(GAME)/build
	$(GODOT) --headless --path $(GAME) --export-debug "Android" build/gulibatto-debug.apk

web: import ## Browser export to game/build/web/ (needs Web export templates)
	@mkdir -p $(GAME)/build/web
	$(GODOT) --headless --path $(GAME) --export-release "Web" build/web/index.html

# ── Marketing site ────────────────────────────────────────────────────

web-dev: ## Run the site at http://localhost:3000
	pnpm --filter web dev

web-lint: ## oxlint (type-aware) on the site and scripts
	pnpm exec oxlint --type-aware web scripts

web-typecheck: ## Type-check the site
	pnpm --filter web typecheck

web-test: ## Unit tests of the site's logic
	pnpm --filter web test

web-build: ## Production build of the site
	pnpm --filter web build

web-smoke: ## Start the built site and check every page (run web-build first)
	pnpm --filter web smoke

# ── Versions ──────────────────────────────────────────────────────────

version: ## Write a new version into every file that carries it (no git): make version v=0.2.0
	@v=$(v) ./scripts/bump-version.sh version

release: ## Bump, commit and push: make release v=0.2.0 (run by you, never automatic)
	@v=$(v) ./scripts/bump-version.sh release
