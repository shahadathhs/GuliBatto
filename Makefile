# Command surface. CI runs the same targets.
GODOT     := godot
GAME      := game
GDTOOLKIT := gdtoolkit==4.5.0
GDLINT    := uvx --from $(GDTOOLKIT) gdlint
GDFORMAT  := uvx --from $(GDTOOLKIT) gdformat
GDPATHS   := $(GAME)/scripts $(GAME)/tests

.DEFAULT_GOAL := help
.PHONY: help import check test lint format run apk web version release

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

import: ## Import assets and build the Godot cache
	$(GODOT) --headless --path $(GAME) --import

check: import ## Load the project headless, then lint and test
	$(GODOT) --headless --path $(GAME) --quit-after 1
	$(MAKE) lint test

test: import ## Run the tests (GUT)
	$(GODOT) --headless --path $(GAME) -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

lint: ## gdlint and gdformat --check
	$(GDLINT) $(GDPATHS)
	$(GDFORMAT) --check $(GDPATHS)

format: ## Fix style in place
	$(GDFORMAT) $(GDPATHS)

run: ## Play on this machine
	$(GODOT) --path $(GAME)

apk: import ## Debug APK to game/build/ (needs Android export templates and SDK)
	@mkdir -p $(GAME)/build
	$(GODOT) --headless --path $(GAME) --export-debug "Android" build/gulibatto-debug.apk

web: import ## Browser export to game/build/web/ (needs Web export templates)
	@mkdir -p $(GAME)/build/web
	$(GODOT) --headless --path $(GAME) --export-release "Web" build/web/index.html

version: ## Write a new version into every file that carries it (no git): make version v=0.2.0
	@v=$(v) ./scripts/bump-version.sh version

release: ## Bump, commit and push: make release v=0.2.0 (run by you, never automatic)
	@v=$(v) ./scripts/bump-version.sh release
