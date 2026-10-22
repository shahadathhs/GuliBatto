# Command surface. CI runs the same targets.
#
#   Game checks and tests   host Godot, or `make game-docker-*` in a container (what CI runs)
#   Every export            the Godot container: `make game-apk|web`
#   GDScript style          gdtoolkit via uv
#   Site and tooling        pnpm

COMPOSE   := docker compose
GODOT     := godot
GAME      := game
GDTOOLKIT := gdtoolkit==4.5.0
GDLINT    := uvx --from $(GDTOOLKIT) gdlint
GDFORMAT  := uvx --from $(GDTOOLKIT) gdformat
GDPATHS   := $(GAME)/scripts $(GAME)/tests
# Headless Godot in the container: import the project, then run the given arguments.
IN_GODOT  := $(COMPOSE) --profile tools run --rm godot

.DEFAULT_GOAL := help
.PHONY: help setup import check lint format test tokens tokens-check colors-check sounds sounds-check content content-check size-check workflows \
        game-check game-test game-lint game-format run \
        game-docker-image game-docker-check game-docker-test game-apk game-web android-key \
        web-lint web-typecheck web-test web-build web-smoke web-dev version release

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-20s %s\n", $$1, $$2}'

setup: ## One-time: install Node tooling (hooks, lint) and build the Godot cache
	pnpm install
	$(MAKE) import

import: ## Import assets and build the Godot cache (host Godot)
	$(GODOT) --headless --path $(GAME) --import

# ── Everything CI checks ──────────────────────────────────────────────

check: lint game-lint game-check test web-typecheck web-build web-smoke ## Everything CI runs, except the exports

lint: tokens-check colors-check sounds-check content-check size-check ## Style gates: prettier, oxlint, tokens, colours, sounds, content, file size
	pnpm exec prettier --check .
	$(MAKE) web-lint

format: game-format ## Fix style in place (gdformat, prettier)
	pnpm exec prettier --write .

test: game-test web-test ## All tests

workflows: ## Lint the GitHub workflow files (actionlint, in a container)
	docker run --rm -v "$$PWD:/repo" -w /repo rhysd/actionlint:1.7.7 -color

# ── Rules that the docs state, enforced ───────────────────────────────

tokens: ## Regenerate the Godot palette and web CSS from design/tokens.json
	node scripts/tokens.mjs

tokens-check: ## Fail if generated colours are out of date or a contrast pair fails
	node scripts/tokens.mjs --check

sounds: ## Regenerate the sound effects in game/audio from scripts/sounds.mjs
	node scripts/sounds.mjs

sounds-check: ## Fail if a sound file differs from what scripts/sounds.mjs makes
	node scripts/sounds.mjs --check

content: ## Regenerate game/data/content.json from content/
	node scripts/content.mjs

content-check: ## Fail if the content is out of date, a link or diagram is broken, or About drifted from its doc
	node scripts/content.mjs --check

colors-check: ## Fail if a colour is written by hand outside the token source
	node scripts/check-colors.mjs

size-check: ## Fail if a source file is over 450 lines (lists files over 300)
	node scripts/check-file-size.mjs

# ── Game (host Godot) ─────────────────────────────────────────────────

game-check: import ## Load the project headless; fails on parse or script errors
	$(GODOT) --headless --path $(GAME) --quit-after 1

game-test: import ## Run the game tests (GUT)
	$(GODOT) --headless --path $(GAME) --fixed-fps 60 -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

game-lint: ## GDScript style gate: gdlint + gdformat --check (config: gdlintrc)
	$(GDLINT) $(GDPATHS)
	$(GDFORMAT) --check $(GDPATHS)

game-format: ## Fix GDScript style in place (gdformat)
	$(GDFORMAT) $(GDPATHS)

run: ## Play on this machine
	$(GODOT) --path $(GAME)

# ── Game (headless Godot in Docker, same result as the host targets) ──

game-docker-image: ## Build the Godot image
	$(COMPOSE) --profile tools build godot

game-docker-check: ## Import and load the project inside the Godot container
	$(IN_GODOT) sh -c 'godot --headless --path . --import && godot --headless --path . --quit-after 1'

game-docker-test: ## Run the game tests inside the Godot container
	$(IN_GODOT) sh -c 'godot --headless --path . --import && godot --headless --path . --fixed-fps 60 -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit'

# ── Exports (the Godot container) ─────────────────────────────────────

game-apk: ## Debug APK to game/build/
	@mkdir -p $(GAME)/build
	$(IN_GODOT) bash -c 'android-setup && godot --headless --path . --import && godot --headless --path . --export-debug "Android" build/gulibatto-debug.apk'
	@echo "Built $(GAME)/build/gulibatto-debug.apk"

game-web: ## Browser export to web/public/play-build/ (the site serves it at /play)
	@mkdir -p $(GAME)/build/web
	$(IN_GODOT) bash -c 'godot --headless --path . --import && godot --headless --path . --export-release "Web" build/web/index.html'
	rm -rf web/public/play-build && mkdir -p web/public/play-build
	cp -R $(GAME)/build/web/. web/public/play-build/
	@echo "Built web/public/play-build (the /play page serves it)"

android-key: ## Print a new debug signing key as base64 (the CI secret): make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64
	@$(IN_GODOT) -T bash -c 'keytool -genkeypair -keyalg RSA -alias androiddebugkey -keypass android -keystore /tmp/k.ks -storepass android -dname "CN=Guli and Batto Debug" -validity 9999 -deststoretype pkcs12 >/dev/null 2>&1 && base64 -w0 /tmp/k.ks' 2>/dev/null | tr -d '\r\n'

# ── Website ───────────────────────────────────────────────────────────

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
