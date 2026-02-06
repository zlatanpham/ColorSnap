.PHONY: build test clean archive open dmg generate help

# Project settings
PROJECT_NAME = MacAppTemplate
SCHEME = $(PROJECT_NAME)
CONFIGURATION = Release
BUILD_DIR = build
ARCHIVE_PATH = $(BUILD_DIR)/$(PROJECT_NAME).xcarchive
EXPORT_PATH = $(BUILD_DIR)/export

# Default target
help:
	@echo "Available targets:"
	@echo "  generate  - Generate Xcode project using xcodegen"
	@echo "  open      - Open project in Xcode"
	@echo "  build     - Build the project"
	@echo "  test      - Run tests"
	@echo "  clean     - Clean build artifacts"
	@echo "  archive   - Create release archive"
	@echo "  dmg       - Create DMG installer"

# Generate Xcode project
generate:
	xcodegen generate

# Open in Xcode
open: generate
	open $(PROJECT_NAME).xcodeproj

# Build
build: generate
	xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(BUILD_DIR) \
		build

# Run tests
test: generate
	xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(BUILD_DIR) \
		test

# Clean
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(PROJECT_NAME).xcodeproj
	xcodebuild clean 2>/dev/null || true

# Archive for release
archive: generate
	xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-archivePath $(ARCHIVE_PATH) \
		archive

# Create DMG
dmg: archive
	npm run build:dmg
