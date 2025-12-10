# Makefile for Flutter projects

.PHONY: all clean install run test format analyze build apk web logs restart killall b64 \
	help fix test-coverage deps \
	create-platform remove-platform \
	create-android create-ios create-linux create-macos create-web create-windows \
	remove-android remove-ios remove-linux remove-macos remove-web remove-windows \
	build-apk build-aab build-ios build-web build-linux build-macos build-windows \
	run-web run-chrome serve

# ==============================================================================
# Variables
# ==============================================================================
APP_NAME = $(shell grep 'name:' pubspec.yaml | awk '{print $$2}')
DEV_DEVICE ?= macos # Default device for 'run'
LAST_LOG_LINES ?= 25 # Default number of lines for 'logs'
WEB_PORT_FILE = .web_port
LAST_RUN_COMMAND_FILE = .last_run_command

# Define color codes for output
INFO := [0;32m
WARN := [0;33m
ERROR := [0;31m
RESET := [0m

# Reusable logic to show URLs
define _SHOW_URLS
	@bash -c ' \
		for i in {1..60}; do \
			if [ -f .$(APP_NAME).log ]; then \
				URL_LINE=$$(grep -m 1 -E "is being served at|is available at|listening on" .$(APP_NAME).log); \
				if [ -n "$$URL_LINE" ]; then \
					URL=$$(echo "$$URL_LINE" | awk '\''{print $$NF}'\''); \
					IP=$$(ip -4 addr show | grep '\''inet '\'' | grep -v 127.0.0.1 | awk '\''{print $$2}'\'' | cut -d/ -f1 | head -n 1); \
					PORT=$$(echo "$$URL" | sed '\''s/.*://'\''); \
					echo "$(INFO)[INFO]$(RESET) App running on $$URL or http://$$IP:$$PORT"; \
					exit 0; \
				fi; \
			fi; \
			sleep 1; \
		done; \
		echo "$(ERROR)[ERROR]$(RESET) Could not determine web server URL from logs after 60 seconds."; \
		tail -n 20 .$(APP_NAME).log; \
		exit 1; \
	'
endef

# ==============================================================================
# Default Target
# ==============================================================================
all: help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# Dependency Management
# ==============================================================================
install: ## Install dependencies
	@echo "$(INFO)[INFO]$(RESET) Getting Flutter dependencies..."
	@flutter pub get

deps: install ## Alias for install

# ==============================================================================
# Running the App
# ==============================================================================
run: clean install ## Run the app on a specified device (default: macos). Usage: make run DEV_DEVICE=linux
	@echo "run" > $(LAST_RUN_COMMAND_FILE)
	@$(MAKE) -s killall
	@echo "$(INFO)[INFO]$(RESET) Running $(APP_NAME) on $(DEV_DEVICE)..."
	@nohup flutter run -d $(DEV_DEVICE) > .$(APP_NAME).log 2>&1 &
	@echo $$! > .$(APP_NAME).pid
	@echo "$(INFO)[INFO]$(RESET) App is running in the background. Logs are in .$(APP_NAME).log"

run-chrome: ## Run the app on Chrome. Uses a random port.
	@echo "run-chrome" > $(LAST_RUN_COMMAND_FILE)
	@$(MAKE) -s killall
	@echo "$(INFO)[INFO]$(RESET) Running $(APP_NAME) on chrome with random port..."
	@nohup stdbuf -o0 flutter run -d chrome --web-port 0 > .$(APP_NAME).log 2>&1 &
	@echo $$! > .$(APP_NAME).pid
	@echo "$(INFO)[INFO]$(RESET) App is running in the background. Waiting for server to start..."
	$(_SHOW_URLS)

serve: ## Serve the web app on 0.0.0.0. Uses a random port.
	@echo "serve" > $(LAST_RUN_COMMAND_FILE)
	@$(MAKE) -s killall
	@echo "$(INFO)[INFO]$(RESET) Running $(APP_NAME) in web server mode..."
	@nohup stdbuf -o0 flutter run -d web-server --web-hostname=0.0.0.0 --web-port=0 > .$(APP_NAME).log 2>&1 &
	@echo $$! > .$(APP_NAME).pid
	@echo "$(INFO)[INFO]$(RESET) App is running in the background. Waiting for server to start..."
	$(_SHOW_URLS)

restart: ## Restart the app using the last run command
	@$(MAKE) -s killall
	@echo "$(INFO)[INFO]$(RESET) Restarting $(APP_NAME)..."
	@sleep 2 # Give some time for processes to terminate
	@if [ -f "$(LAST_RUN_COMMAND_FILE)" ]; then \
		LAST_COMMAND=$$(cat $(LAST_RUN_COMMAND_FILE)); \
		echo "$(INFO)[INFO]$(RESET) Restarting with last command: 'make $$LAST_COMMAND'"; \
		$(MAKE) -s $$LAST_COMMAND; \
	else \
		echo "$(WARN)[WARN]$(RESET) '.last_run_command' file not found, defaulting to 'make run'"; \
		$(MAKE) -s run; \
	fi

# ==============================================================================
# Testing & Analysis
# ==============================================================================
test: install ## Run tests
	@echo "$(INFO)[INFO]$(RESET) Running tests for $(APP_NAME)..."
	@flutter test

test-coverage: install ## Run tests and generate coverage report
	@echo "$(INFO)[INFO]$(RESET) Running tests with coverage for $(APP_NAME)..."
	@flutter test --coverage
	@echo "$(INFO)[INFO]$(RESET) Coverage report generated in coverage/lcov.info"

format: ## Format code
	@echo "$(INFO)[INFO]$(RESET) Formatting code..."
	@dart format .

analyze: ## Analyze code
	@echo "$(INFO)[INFO]$(RESET) Analyzing code..."
	@flutter analyze

fix: ## Apply dart fixes
	@echo "$(INFO)[INFO]$(RESET) Applying dart fixes..."
	@dart fix --apply .


lint: ## Lint code
	@echo "$(INFO)[INFO]$(RESET) Linting code..."
	@$(MAKE) -s format
	@$(MAKE) -s fix
	@$(MAKE) -s analyze

# ==============================================================================
# Building
# ==============================================================================
build: ## Build for a specific platform. Usage: make build PLATFORM=linux
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) for $(PLATFORM)..."
	@flutter build $(PLATFORM)

build-apk: clean install ## Build Android APK
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) apk..."
	@flutter build apk --release --split-per-abi --split-debug-info .debug
	@echo "$(INFO)[INFO]$(RESET) App is built in build/app/outputs/flutter-apk/"

build-aab: clean install ## Build Android App Bundle
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) appbundle..."
	@flutter build appbundle --release --split-debug-info .debug
	@echo "$(INFO)[INFO]$(RESET) App is built in build/app/outputs/bundle/release/"

build-ios: clean install ## Build iOS app
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) for iOS..."
	@flutter build ios --release --no-codesign

build-web: clean install ## Build web app
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) for web..."
	@flutter build web --release --wasm -O4

build-linux: clean install ## Build Linux app
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) for Linux..."
	@flutter build linux --release

build-macos: clean install ## Build macOS app
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) for macOS..."
	@flutter build macos --release

build-windows: ## Build Windows app
	@echo "$(INFO)[INFO]$(RESET) Building $(APP_NAME) for Windows..."
	@flutter build windows --release

# ==============================================================================
# Platform Management
# ==============================================================================
create-platform: ## Create platform-specific code. Usage: make create-platform PLATFORM=windows
	@if [ -z "$(PLATFORM)" ]; then \
		echo "$(ERROR)[ERROR]$(RESET) PLATFORM variable is not set. Usage: make create-platform PLATFORM=<platform>"; \
		exit 1; \
	fi
	@echo "$(INFO)[INFO]$(RESET) Creating platform code for $(PLATFORM)..."
	@flutter create --platform=$(PLATFORM) --org=dev.hafijul .

remove-platform: ## DANGEROUS: Remove platform-specific code. Usage: make remove-platform PLATFORM=windows
	@if [ -z "$(PLATFORM)" ]; then \
		echo "$(ERROR)[ERROR]$(RESET) PLATFORM variable is not set. Usage: make remove-platform PLATFORM=<platform>"; \
		exit 1; \
	fi
	@echo "$(WARN)[WARN]$(RESET) This will permanently delete the '$(PLATFORM)' directory. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@echo "$(INFO)[INFO]$(RESET) Removing platform code for $(PLATFORM)..."
	@rm -rf $(PLATFORM)

create: ## Create all platform code
	@$(MAKE) -s create-platform PLATFORM=android
	@$(MAKE) -s create-platform PLATFORM=ios
	@$(MAKE) -s create-platform PLATFORM=linux
	@$(MAKE) -s create-platform PLATFORM=macos
	@$(MAKE) -s create-platform PLATFORM=windows

create-android: ## Create Android platform code
	@$(MAKE) -s create-platform PLATFORM=android

create-ios: ## Create iOS platform code
	@$(MAKE) -s create-platform PLATFORM=ios

create-linux: ## Create Linux platform code
	@$(MAKE) -s create-platform PLATFORM=linux

create-macos: ## Create macOS platform code
	@$(MAKE) -s create-platform PLATFORM=macos

create-web: ## Create web platform code
	@$(MAKE) -s create-platform PLATFORM=web

create-windows: ## Create Windows platform code
	@$(MAKE) -s create-platform PLATFORM=windows

remove-android: ## DANGEROUS: Remove Android platform code
	@$(MAKE) -s remove-platform PLATFORM=android

remove-ios: ## DANGEROUS: Remove iOS platform code
	@$(MAKE) -s remove-platform PLATFORM=ios

remove-linux: ## DANGEROUS: Remove Linux platform code
	@$(MAKE) -s remove-platform PLATFORM=linux

remove-macos: ## DANGEROUS: Remove macOS platform code
	@$(MAKE) -s remove-platform PLATFORM=macos

remove-web: ## DANGEROUS: Remove web platform code
	@$(MAKE) -s remove-platform PLATFORM=web

remove-windows: ## DANGEROUS: Remove Windows platform code
	@$(MAKE) -s remove-platform PLATFORM=windows

remove: ## DANGEROUS: Remove all platform code
	@$(MAKE) -s remove-platform PLATFORM=android
	@$(MAKE) -s remove-platform PLATFORM=ios
	@$(MAKE) -s remove-platform PLATFORM=linux
	@$(MAKE) -s remove-platform PLATFORM=macos
	@$(MAKE) -s remove-platform PLATFORM=windows

# ==============================================================================
# Utilities & Cleanup
# ==============================================================================
clean: ## Clean build artifacts
	@echo "$(INFO)[INFO]$(RESET) Cleaning build artifacts..."
	@flutter clean
	@rm -f .$(APP_NAME).log .$(APP_NAME).pid $(LAST_RUN_COMMAND_FILE)

logs: ## Show logs. Usage: make logs LAST_LOG_LINES=50
	@echo "$(INFO)[INFO]$(RESET) Showing last $(LAST_LOG_LINES) lines of .$(APP_NAME).log"
	@tail -n $(LAST_LOG_LINES) .$(APP_NAME).log

killall: ## Kill all running instances of the app
	@echo "$(INFO)[INFO]$(RESET) Killing all instances of $(APP_NAME)..."
	@if [ -f .$(APP_NAME).pid ]; then \
		PID=$$(cat .$(APP_NAME).pid); \
		if [ -n "$$PID" ]; then \
			echo "$(INFO)[INFO]$(RESET) Found PID $$PID from .$(APP_NAME).pid. Killing it..."; \
			kill -9 $$PID 2>/dev/null || true; \
		fi; \
	fi
	@if [ -f $(WEB_PORT_FILE) ]; then \
		PORT=$$(cat $(WEB_PORT_FILE)); \
		if [ -n "$$PORT" ]; then \
			PID=$$(ss -tulnp | grep ":$$PORT" | awk -F'pid=' '{print $$2}' | awk -F',' '{print $$1}') ; \
			if [ -n "$$PID" ]; then \
				echo "$(WARN)[WARN]$(RESET) Found process $$PID listening on port $$PORT. Killing it..."; \
				kill -9 $$PID 2>/dev/null || true; \
			fi; \
		fi; \
	fi
	@rm -f .$(APP_NAME).pid $(WEB_PORT_FILE)
	@echo "$(INFO)[INFO]$(RESET) All instances of $(APP_NAME) killed."

b64: ## Convert Android keystore to base64
	@if [ -f android/android-prod.keystore ]; then \
		echo "$(INFO)[INFO]$(RESET) Converting android/android-prod.keystore to base64..."; \
		base64 -i android/android-prod.keystore > android/.android-prod.keystore.base64; \
		echo "$(INFO)[INFO]$(RESET) Base64 content written to android/.android-prod.keystore.base64"; \
	else \
		echo "$(ERROR)[ERROR]$(RESET) android/android-prod.keystore not found."; \
		exit 1; \
	fi
