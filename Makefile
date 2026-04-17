# HerdMaster — developer commands
.PHONY: help test test-core build format lint clean xcode design

SWIFT ?= swift

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: ## Run every test in the package
	$(SWIFT) test

test-core: ## Run only platform-agnostic Core tests (works on Linux)
	$(SWIFT) test --filter HerdMasterCoreTests

build: ## Build HerdMasterCore (portable) and HerdMasterUI (Apple platforms)
	$(SWIFT) build

format: ## Format every Swift source via swift-format
	@command -v swift-format >/dev/null || { echo "swift-format not found — install via brew or apt"; exit 1; }
	swift-format format --in-place --recursive Sources Tests

lint: ## Lint every Swift source via SwiftLint
	@command -v swiftlint >/dev/null || { echo "swiftlint not found — install via brew"; exit 1; }
	swiftlint lint --strict

clean: ## Remove build artifacts
	rm -rf .build .swiftpm

xcode: ## Regenerate Xcode project from project.yml (requires xcodegen)
	@command -v xcodegen >/dev/null || { echo "xcodegen not found — brew install xcodegen"; exit 1; }
	xcodegen generate

design: ## Serve the web design system at http://localhost:8765
	@cd Design && python3 -m http.server 8765
