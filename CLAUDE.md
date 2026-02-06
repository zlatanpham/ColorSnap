# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
make generate  # Generate Xcode project from project.yml (requires xcodegen)
make open      # Generate and open in Xcode
make build     # Build release binary
make test      # Run unit tests
make clean     # Clean all build artifacts
make archive   # Create .xcarchive for release
make dmg       # Create DMG installer (requires archive first)
```

**Requirements:** macOS 14.0+, Xcode 15.0+, XcodeGen (`brew install xcodegen`)

## Architecture

ColorSnap is a macOS menu bar color picker using **MVVM** with SwiftUI:

- **Models/** - `ColorFormat` (enum: hex/rgb/hsl/hsb), `PickedColor` (stores RGBA components, Codable)
- **Views/** - `ColorPreviewView` (swatch + format rows), `ColorHistoryView`, `ColorRowView`, `SettingsView`
- **ViewModels/** - `ColorPickerViewModel` (@MainActor state management)
- **Services/** - `ColorPickerService` (NSColorSampler wrapper), `ColorStorageService` (UserDefaults persistence)
- **Extensions/** - `NSColor+Formats` (color format conversion)

### Key Patterns

**Actor-based concurrency:** `ColorPickerService` and `ColorStorageService` are actors ensuring thread-safe operations.

**NSColorSampler integration:** Color picking uses macOS native `NSColorSampler` wrapped in `withCheckedContinuation` for async/await.

**UserDefaults persistence:** Color history stored as JSON in UserDefaults, max 100 colors, newest-first ordering.

**Menu bar integration:** `AppDelegate` manages NSStatusItem + NSPopover lifecycle. Uses `.accessory` activation policy (no Dock icon), switches to `.regular` only when Settings window is shown.

### Key Files

- `AppDelegate.swift` - Menu bar setup, popover management, global click monitoring
- `ColorPickerViewModel.swift` - Central state management (pick, copy, history)
- `ColorPickerService.swift` - NSColorSampler async wrapper
- `ColorStorageService.swift` - UserDefaults-based color history persistence
- `NSColor+Formats.swift` - HEX, RGB, HSL, HSB format conversion
- `LaunchAtLoginManager.swift` - ServiceManagement integration for auto-launch

## Configuration

- **Info.plist:** `LSUIElement=true` hides app from Dock
- **Entitlements:** App sandbox enabled + network client access
- **project.yml:** XcodeGen configuration (bundle ID: `com.example.ColorSnap`)

## Git Hooks

Husky enforces conventional commits:

- `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`
- Example: `feat(picker): add HSL format support`

Prettier runs on staged `*.{js,json,md}` files via lint-staged.
