DOCUMENTS_DIR := $(HOME)/Documents
APP_NAME := Rafeeq
CURRENT_DATE := $(shell date +"%I-%M %p")
AAB_OUTPUT_PATH := build/app/outputs/bundle/release/app-release.aab
APK_OUTPUT_PATH := build/app/outputs/flutter-apk/app-release.apk

bundle:
	@echo "Building AAB Bundle ..."
	flutter build appbundle --release
	@echo "Copying AAB To Documents Directory ..."
	mkdir -p "$(DOCUMENTS_DIR)/$(APP_NAME)"
	cp $(AAB_OUTPUT_PATH) "$(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).aab"
	@echo "AAB Bundle Created And Copied To $(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).aab"

bundle-optimized:
	@echo "Cleaning Flutter Project ..."
	flutter clean
	@echo "Cleaning Android Build ..."
	cd android && ./gradlew clean
	@echo "Getting Flutter Dependencies ..."
	flutter pub get
	@echo "Building AAB Bundle ..."
	flutter build appbundle --release
	@echo "Copying AAB To Documents Directory ..."
	mkdir -p "$(DOCUMENTS_DIR)/$(APP_NAME)"
	cp $(AAB_OUTPUT_PATH) "$(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).aab"
	@echo "AAB Bundle Created And Copied To $(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).aab"
	@echo "Optimized Bundle Build Complete!"

apk:
	@echo "Building APK ..."
	flutter build apk --release
	@echo "Copying APK To Documents Directory ..."
	mkdir -p "$(DOCUMENTS_DIR)/$(APP_NAME)"
	cp $(APK_OUTPUT_PATH) "$(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).apk"
	@echo "APK Created And Copied To $(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).apk"

apk-optimized:
	@echo "Cleaning Flutter Project ..."
	flutter clean
	@echo "Cleaning Android Build ..."
	cd android && ./gradlew clean
	@echo "Getting Flutter Dependencies ..."
	flutter pub get
	@echo "Building APK ..."
	flutter build apk --release
	@echo "Copying APK To Documents Directory ..."
	mkdir -p "$(DOCUMENTS_DIR)/$(APP_NAME)"
	cp $(APK_OUTPUT_PATH) "$(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).apk"
	@echo "APK Created And Copied To $(DOCUMENTS_DIR)/$(APP_NAME)/$(APP_NAME) $(CURRENT_DATE).apk"
	@echo "Optimized APK Build Complete!"

shorebird-check:
	@echo "=========================================="
	@echo "  Shorebird Setup Check"
	@echo "=========================================="
	@if ! command -v shorebird > /dev/null 2>&1; then \
		echo "❌ Shorebird CLI Not Found"; \
		echo "   Install it from https://docs.shorebird.dev/ before running Shorebird commands."; \
		exit 1; \
	fi
	@if [ ! -f "shorebird.yaml" ]; then \
		echo "❌ shorebird.yaml Not Found"; \
		echo "   Run: shorebird init --display-name \"$(APP_NAME)\""; \
		exit 1; \
	fi
	@if ! grep -q "shorebird.yaml" pubspec.yaml; then \
		echo "❌ shorebird.yaml Is Not Listed In pubspec.yaml Assets"; \
		echo "   Run: shorebird init --display-name \"$(APP_NAME)\""; \
		exit 1; \
	fi
	@echo "✅ Shorebird CLI Found"
	@echo "✅ shorebird.yaml Found"
	@echo "✅ shorebird.yaml Is Bundled As An Asset"

shorebird-init:
	shorebird init --display-name "$(APP_NAME)"

shorebird-login:
	shorebird login

shorebird-logout:
	shorebird logout

shorebird-doctor:
	shorebird doctor

shorebird-release-android: shorebird-check
	shorebird release android

shorebird-release-android-apk: shorebird-check
	shorebird release android --artifact apk

shorebird-patch-android: shorebird-check
	shorebird patch android --release-version latest

shorebird-patch-android-staging: shorebird-check
	shorebird patch android --release-version latest --track staging

sort-arb:
	@echo "Sorting ARB Files ..."
	python3 sort_arb.py
	@echo "ARB Files Sorted Successfully!"

verify-arb:
	@echo "Verifying ARB Files for missing keys ..."
	python3 verify_arb.py

json:
	@echo "Exporting JSON ..."
	python3 export_json.py
	@echo "JSON Export Complete!"

verify:
	@echo "=========================================="
	@echo "  Keystore Verification"
	@echo "=========================================="
	@echo ""
	@KEY_PROPS="android/key.properties"; \
	if [ ! -f "$$KEY_PROPS" ]; then \
		echo "❌ FAILED: key.properties Not Found At $$KEY_PROPS"; \
		exit 1; \
	else \
		echo "✅ key.properties Found"; \
	fi; \
	KEY_ALIAS=$$(grep -E "^keyAlias=" "$$KEY_PROPS" | cut -d'=' -f2-); \
	KEY_PASSWORD=$$(grep -E "^keyPassword=" "$$KEY_PROPS" | cut -d'=' -f2-); \
	STORE_FILE=$$(grep -E "^storeFile=" "$$KEY_PROPS" | cut -d'=' -f2-); \
	STORE_PASSWORD=$$(grep -E "^storePassword=" "$$KEY_PROPS" | cut -d'=' -f2-); \
	echo ""; \
	echo "-- Properties Check --"; \
	MISSING=0; \
	if [ -z "$$KEY_ALIAS" ]; then \
		echo "❌ keyAlias: MISSING"; \
		MISSING=1; \
	else \
		echo "✅ keyAlias: $$KEY_ALIAS"; \
	fi; \
	if [ -z "$$KEY_PASSWORD" ]; then \
		echo "❌ keyPassword: MISSING"; \
		MISSING=1; \
	else \
		echo "✅ keyPassword: [SET]"; \
	fi; \
	if [ -z "$$STORE_FILE" ]; then \
		echo "❌ storeFile: MISSING"; \
		MISSING=1; \
	else \
		echo "✅ storeFile: $$STORE_FILE"; \
	fi; \
	if [ -z "$$STORE_PASSWORD" ]; then \
		echo "❌ storePassword: MISSING"; \
		MISSING=1; \
	else \
		echo "✅ storePassword: [SET]"; \
	fi; \
	echo ""; \
	echo "-- Keystore File Check --"; \
	if [ -z "$$STORE_FILE" ]; then \
		echo "⚠️  Cannot Verify Keystore File (StoreFile Not Set)"; \
		exit 1; \
	elif [ -f "$$STORE_FILE" ]; then \
		echo "✅ Keystore File Exists: $$STORE_FILE"; \
	else \
		echo "❌ Keystore File NOT FOUND: $$STORE_FILE"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "-- Keystore Credentials Check --"; \
	if keytool -list -keystore "$$STORE_FILE" -storepass "$$STORE_PASSWORD" > /dev/null 2>&1; then \
		echo "✅ Store Password Is CORRECT"; \
	else \
		echo "❌ Store Password Is INCORRECT Or Keystore Is Corrupted"; \
		MISSING=1; \
	fi; \
	if keytool -list -keystore "$$STORE_FILE" -storepass "$$STORE_PASSWORD" -alias "$$KEY_ALIAS" > /dev/null 2>&1; then \
		echo "✅ Key Alias '$$KEY_ALIAS' Exists In Keystore"; \
	else \
		echo "❌ Key Alias '$$KEY_ALIAS' NOT FOUND In Keystore"; \
		MISSING=1; \
	fi; \
	if keytool -keypasswd -keystore "$$STORE_FILE" -storepass "$$STORE_PASSWORD" -alias "$$KEY_ALIAS" -keypass "$$KEY_PASSWORD" -new "$$KEY_PASSWORD" > /dev/null 2>&1; then \
		echo "✅ Key Password Is CORRECT"; \
	else \
		echo "❌ Key Password Is INCORRECT"; \
		MISSING=1; \
	fi; \
	echo ""; \
	if [ $$MISSING -eq 1 ]; then \
		echo "========================================"; \
		echo "  ❌ VERIFICATION FAILED"; \
		echo "========================================"; \
		exit 1; \
	else \
		echo "========================================"; \
		echo "  ✅ ALL CHECKS PASSED"; \
		echo "========================================"; \
	fi

setup-fastlane:
	@echo "=========================================="
	@echo "  Setting Up Fastlane (Android)"
	@echo "=========================================="
	@if ! command -v fastlane > /dev/null 2>&1; then \
		echo "Installing Fastlane ..."; \
		sudo gem install fastlane -NV; \
	else \
		echo "✅ Fastlane Already Installed"; \
	fi
	@echo ""
	@echo "-- Initializing Fastlane For Android --"
	cd android && fastlane init
	@echo ""
	@echo "=========================================="
	@echo "  ⚠️  IMPORTANT NEXT STEPS"
	@echo "=========================================="
	@echo ""
	@echo "📱 ANDROID:"
	@echo "  1. Download Service Account JSON From Google Play Console:"
	@echo "     - Go To: Play Console > Setup > API Access"
	@echo "     - Create/Download Service Account Key"
	@echo "     - Save As: android/fastlane/service_account.json"
	@echo ""
	@echo "Run 'make verify-fastlane' To Verify Setup"
	@echo "=========================================="

verify-fastlane:
	@echo "=========================================="
	@echo "  Fastlane Setup Verification"
	@echo "=========================================="
	@echo ""
	@FAILED=0; \
	if ! command -v fastlane > /dev/null 2>&1; then \
		echo "❌ Fastlane Is NOT Installed"; \
		echo ""; \
		echo "To Install Fastlane:"; \
		echo "  sudo gem install fastlane -NV"; \
		echo "  or"; \
		echo "  brew install fastlane"; \
		exit 1; \
	else \
		echo "✅ Fastlane Is Installed ($$(fastlane --version | head -n1))"; \
	fi; \
	echo ""; \
	echo "-- Android Checks --"; \
	if [ ! -f "android/fastlane/Fastfile" ]; then \
		echo "❌ Android Fastfile Not Found"; \
		FAILED=1; \
	else \
		echo "✅ Android Fastfile Found"; \
	fi; \
	if [ ! -f "android/fastlane/service_account.json" ]; then \
		echo "⚠️  Android service_account.json Not Found"; \
		echo "   Download From Google Play Console > Setup > API access"; \
		FAILED=1; \
	else \
		echo "✅ Android service_account.json Found"; \
	fi; \
	echo ""; \
	if [ $$FAILED -eq 1 ]; then \
		echo "========================================"; \
		echo "  ⚠️  SOME CHECKS FAILED"; \
		echo "========================================"; \
		exit 1; \
	else \
		echo "========================================"; \
		echo "  ✅ FASTLANE SETUP COMPLETE"; \
		echo "========================================"; \
	fi

upload-shorebird-android-internal: shorebird-release-android
	@echo "=========================================="
	@echo "  Uploading Shorebird AAB to Play Store (Internal Testing)"
	@echo "=========================================="
	@echo "✅ Fresh Shorebird AAB Bundle Created"
	@VERSION_CODE=$$(grep -E "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f2); \
	echo "Version Code: $$VERSION_CODE"; \
	CHANGELOG_DIR="android/fastlane/metadata/android/en-US/changelogs"; \
	mkdir -p "$$CHANGELOG_DIR"; \
	if [ -f "RELEASE_NOTES.txt" ]; then \
		RELEASE_TEXT=$$(cat RELEASE_NOTES.txt | grep -v '^#' | grep -v '^$$' | head -c 500); \
		cp RELEASE_NOTES.txt "$$CHANGELOG_DIR/$$VERSION_CODE.txt"; \
		cp RELEASE_NOTES.txt "$$CHANGELOG_DIR/default.txt"; \
		echo "✅ Release Notes Copied To $$CHANGELOG_DIR/$$VERSION_CODE.txt"; \
		echo ""; \
		echo "Release Notes Preview:"; \
		echo "$$RELEASE_TEXT"; \
		echo ""; \
	else \
		echo "⚠️  No RELEASE_NOTES.txt Found. Uploading Without Release Notes ..."; \
	fi
	@echo "Uploading To Internal Testing Track ..."
	cd android && fastlane supply \
		--aab ../$(AAB_OUTPUT_PATH) \
		--track internal \
		--json_key fastlane/service_account.json \
		--package_name com.satechdev.rafeeqapp \
		--skip_upload_images \
		--skip_upload_screenshots
	@echo ""
	@echo "=========================================="
	@echo "  ✅ SHOREBIRD UPLOAD COMPLETE (Internal Testing)"
	@echo "=========================================="

upload-shorebird-android: shorebird-release-android
	@echo "=========================================="
	@echo "  Uploading Shorebird AAB to Play Store (Production)"
	@echo "=========================================="
	@echo "✅ Fresh Shorebird AAB Bundle Created"
	@VERSION_CODE=$$(grep -E "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f2); \
	echo "Version Code: $$VERSION_CODE"; \
	CHANGELOG_DIR="android/fastlane/metadata/android/en-US/changelogs"; \
	mkdir -p "$$CHANGELOG_DIR"; \
	if [ -f "RELEASE_NOTES.txt" ]; then \
		RELEASE_TEXT=$$(cat RELEASE_NOTES.txt | grep -v '^#' | grep -v '^$$' | head -c 500); \
		cp RELEASE_NOTES.txt "$$CHANGELOG_DIR/$$VERSION_CODE.txt"; \
		cp RELEASE_NOTES.txt "$$CHANGELOG_DIR/default.txt"; \
		echo "✅ Release Notes Copied To $$CHANGELOG_DIR/$$VERSION_CODE.txt"; \
		echo ""; \
		echo "Release Notes Preview:"; \
		echo "$$RELEASE_TEXT"; \
		echo ""; \
	else \
		echo "⚠️  No RELEASE_NOTES.txt Found. Uploading Without Release Notes ..."; \
	fi
	@echo "Uploading To Production Track ..."
	cd android && fastlane supply \
		--aab ../$(AAB_OUTPUT_PATH) \
		--track production \
		--json_key fastlane/service_account.json \
		--package_name com.satechdev.rafeeqapp \
		--skip_upload_images \
		--skip_upload_screenshots
	@echo ""
	@echo "=========================================="
	@echo "  ✅ SHOREBIRD UPLOAD COMPLETE (Production)"
	@echo "=========================================="

version-increment:
	@echo "==========================================="
	@echo "  Incrementing Version"
	@echo "==========================================="
	@CURRENT_VERSION=$$(grep -E "^version:" pubspec.yaml | sed 's/version: //'); \
	echo "Current Version: $$CURRENT_VERSION"; \
	MAJOR=$$(echo $$CURRENT_VERSION | cut -d'.' -f1); \
	MINOR=$$(echo $$CURRENT_VERSION | cut -d'.' -f2); \
	PATCH=$$(echo $$CURRENT_VERSION | cut -d'.' -f3 | cut -d'+' -f1); \
	BUILD=$$(echo $$CURRENT_VERSION | cut -d'+' -f2); \
	NEW_PATCH=$$((PATCH + 1)); \
	NEW_BUILD=$$((BUILD + 1)); \
	NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH+$$NEW_BUILD"; \
	TAG="v$$MAJOR.$$MINOR.$$NEW_PATCH-$$NEW_BUILD"; \
	echo "New version: $$NEW_VERSION"; \
	echo "Tag: $$TAG"; \
	echo ""; \
	echo "-- Updating pubspec.yaml --"; \
	sed -i '' "s/^version: .*/version: $$NEW_VERSION/" pubspec.yaml; \
	echo "✅ pubspec.yaml Updated"; \
	echo ""; \
	echo "-- Creating Git Tag --"; \
	git tag "$$TAG"; \
	echo "✅ Git Tag Created: $$TAG"; \
	git push origin "$$TAG"; \
	echo "✅ Git Tag Pushed: $$TAG"; \
	echo ""; \
	echo "========================================="; \
	echo "  ✅ VERSION INCREMENTED"; \
	echo "  $$CURRENT_VERSION → $$NEW_VERSION"; \
	echo "  🏷️  Tag: $$TAG"; \
	echo "========================================="

version-decrement:
	@echo "==========================================="
	@echo "  Decrementing Version"
	@echo "==========================================="
	@CURRENT_VERSION=$$(grep -E "^version:" pubspec.yaml | sed 's/version: //'); \
	echo "Current version: $$CURRENT_VERSION"; \
	MAJOR=$$(echo $$CURRENT_VERSION | cut -d'.' -f1); \
	MINOR=$$(echo $$CURRENT_VERSION | cut -d'.' -f2); \
	PATCH=$$(echo $$CURRENT_VERSION | cut -d'.' -f3 | cut -d'+' -f1); \
	BUILD=$$(echo $$CURRENT_VERSION | cut -d'+' -f2); \
	if [ $$PATCH -le 0 ] || [ $$BUILD -le 1 ]; then \
		echo "❌ Cannot Decrement: Version Is Already At Minimum"; \
		exit 1; \
	fi; \
	TAG="v$$MAJOR.$$MINOR.$$PATCH-$$BUILD"; \
	NEW_PATCH=$$((PATCH - 1)); \
	NEW_BUILD=$$((BUILD - 1)); \
	NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH+$$NEW_BUILD"; \
	echo "New version: $$NEW_VERSION"; \
	echo ""; \
	echo "-- Updating pubspec.yaml --"; \
	sed -i '' "s/^version: .*/version: $$NEW_VERSION/" pubspec.yaml; \
	echo "✅ pubspec.yaml Updated"; \
	echo ""; \
	echo "-- Removing Git Tag --"; \
	if git tag -l "$$TAG" | grep -q "$$TAG"; then \
		git tag -d "$$TAG"; \
		echo "✅ Local Tag Deleted: $$TAG"; \
		if git ls-remote --tags origin "$$TAG" 2>/dev/null | grep -q "$$TAG"; then \
			git push origin --delete "$$TAG" 2>/dev/null && \
			echo "✅ Remote Tag Deleted: $$TAG" || \
			echo "⚠️  Could Not Delete Remote Tag (May Not Exist)"; \
		else \
			echo "ℹ️  Tag Was Not Pushed To Remote"; \
		fi; \
	else \
		echo "⚠️  Tag $$TAG Not Found Locally (Skipping)"; \
	fi; \
	echo ""; \
	echo "========================================="; \
	echo "  ✅ VERSION DECREMENTED"; \
	echo "  $$CURRENT_VERSION → $$NEW_VERSION"; \
	echo "  🏷️  Tag Removed: $$TAG"; \
	echo "========================================="

help:
	@echo "Available commands:"
	@echo ""
	@echo "Build Commands:"
	@echo "  make bundle           - Build AAB Bundle (Quick)"
	@echo "  make bundle-optimized - Clean + Get + Build AAB Bundle"
	@echo "  make apk              - Build APK (Quick)"
	@echo "  make apk-optimized    - Clean + Get + Build APK"
	@echo ""
	@echo "Shorebird Commands:"
	@echo "  make shorebird-init                  - Initialize Shorebird for this app"
	@echo "  make shorebird-login                 - Log in to Shorebird"
	@echo "  make shorebird-logout                - Log out of Shorebird"
	@echo "  make shorebird-check                 - Verify Shorebird CLI and project config"
	@echo "  make shorebird-doctor                - Run Shorebird environment checks"
	@echo "  make shorebird-release-android       - Build/upload Shorebird Android AAB release"
	@echo "  make shorebird-release-android-apk   - Build/upload Shorebird Android APK release"
	@echo "  make shorebird-patch-android         - Publish Android patch to stable"
	@echo "  make shorebird-patch-android-staging - Publish Android patch to staging"
	@echo ""
	@echo "Test Commands:"
	@echo "  make test-coverage      - Run tests with coverage and generate HTML report"
	@echo "  make test-coverage-open - Run tests with coverage and open HTML report"
	@echo ""
	@echo "Verification Commands:"
	@echo "  make verify           - Verify Keystore Configuration"
	@echo "  make verify-fastlane  - Verify Fastlane Setup (Android)"
	@echo ""
	@echo "Fastlane Setup:"
	@echo "  make setup-fastlane   - Initial Fastlane Setup (Android)"
	@echo ""
	@echo "Upload Commands:"
	@echo "  make upload-shorebird-android          - Shorebird release + Upload AAB to Production"
	@echo "  make upload-shorebird-android-internal - Shorebird release + Upload AAB to Internal Testing"
	@echo ""
	@echo "Localization Commands:"
	@echo "  make sort-arb         - Sort ARB keys A-Z & remove duplicates"
	@echo "  make verify-arb       - Verify ARB files for missing keys"
	@echo ""
	@echo "Version Management:"
	@echo "  make version-increment - Increment Patch Version (e.g., 1.3.20+42 → 1.3.21+43)"
	@echo "  make version-decrement - Decrement Patch Version (e.g., 1.3.21+43 → 1.3.20+42)"

test-coverage:
	@echo "=========================================="
	@echo "  Running Tests with Coverage"
	@echo "=========================================="
	@flutter test --coverage
	@echo ""
	@echo "Coverage report generated at: coverage/lcov.info"
	@if command -v genhtml > /dev/null 2>&1; then \
		echo "Generating HTML report..."; \
		genhtml coverage/lcov.info -o coverage/html --no-function-coverage -s -p $(PWD); \
		echo ""; \
		echo "=========================================="; \
		echo "  ✅ HTML Report Generated"; \
		echo "  📁 coverage/html/index.html"; \
		echo "=========================================="; \
		echo ""; \
		echo "To view: open coverage/html/index.html"; \
	else \
		echo ""; \
		echo "⚠️  genhtml not found (install lcov for HTML reports)"; \
		echo ""; \
		echo "To install on macOS:"; \
		echo "  brew install lcov"; \
		echo ""; \
		echo "Raw coverage data available at: coverage/lcov.info"; \
	fi

test-coverage-open: test-coverage
	@if [ -f coverage/html/index.html ]; then \
		open coverage/html/index.html; \
	else \
		echo "HTML report not found. Run 'make test-coverage' first."; \
	fi

.PHONY: bundle bundle-optimized apk apk-optimized shorebird-check shorebird-init shorebird-login shorebird-logout shorebird-doctor shorebird-release-android shorebird-release-android-apk shorebird-patch-android shorebird-patch-android-staging sort-arb verify-arb json help verify verify-fastlane setup-fastlane upload-shorebird-android upload-shorebird-android-internal version-increment version-decrement test-coverage test-coverage-open
