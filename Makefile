WEB_EXT  ?= npx --yes web-ext
DIST     ?= dist
URL      ?= https://app.slack.com
CHROMIUM ?= $(shell command -v chromium chromium-browser google-chrome 2>/dev/null | head -n1)
CHANNEL  ?= listed

VERSION  := $(shell sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' manifest.json)
IGNORE   := --ignore-files Makefile README.md LICENSE slack-app-in-tab-logo.svg '$(DIST)/**'

.DEFAULT_GOAL := help
.PHONY: help lint test run run-firefox run-chromium build sign clean

help: ## Show this help message
	@echo "Slack App-in-Tab $(VERSION)"
	@echo
	@echo "Usage: make <target> [VAR=value]"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk -F ':.*## ' '{ printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 }'
	@echo
	@echo "Variables:"
	@echo "  URL            Page opened by the run targets ($(URL))"
	@echo "  CHROMIUM       Chromium binary ($(CHROMIUM))"
	@echo "  CHANNEL        AMO channel for sign: listed or unlisted ($(CHANNEL))"
	@echo "  WEB_AMO_API_KEY / WEB_AMO_API_SECRET  AMO credentials for sign"

lint: ## Validate the manifest and sources with web-ext lint
	$(WEB_EXT) lint $(IGNORE)

test: lint ## Run all checks (syntax check and lint)
	node --check contentScript.js

run: run-firefox ## Alias for run-firefox

run-firefox: ## Start Firefox with a temporary profile and the extension loaded
	$(WEB_EXT) run --target firefox-desktop --start-url $(URL) $(IGNORE)

run-chromium: ## Start Chromium with a temporary profile and the extension loaded
	$(WEB_EXT) run --target chromium --chromium-binary "$(CHROMIUM)" --start-url $(URL) $(IGNORE)

build: test ## Build the zip to upload to AMO or the Chrome Web Store
	$(WEB_EXT) build --overwrite-dest --artifacts-dir $(DIST) \
		--filename slack-app-in-tab-$(VERSION).zip $(IGNORE)

sign: test ## Submit to AMO for signing (needs WEB_AMO_API_KEY/SECRET)
	@test -n "$$WEB_AMO_API_KEY" -a -n "$$WEB_AMO_API_SECRET" || \
		{ echo "Set WEB_AMO_API_KEY and WEB_AMO_API_SECRET (https://addons.mozilla.org/developers/addon/api/key/)"; exit 1; }
	$(WEB_EXT) sign --channel $(CHANNEL) --artifacts-dir $(DIST) \
		--api-key "$$WEB_AMO_API_KEY" --api-secret "$$WEB_AMO_API_SECRET" $(IGNORE)

clean: ## Remove build artifacts
	rm -rf $(DIST)
