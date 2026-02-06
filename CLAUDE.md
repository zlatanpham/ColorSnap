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

This is a macOS menu bar application using **MVVM** with SwiftUI:

- **Models/** - Pure data structures (Codable, Hashable)
- **Views/** - Stateless SwiftUI presentation components
- **ViewModels/** - @MainActor state management with @Published properties
- **Services/** - Actor-based business logic (thread-safe)

### Key Patterns

**Actor-based concurrency:** `APIService` is an actor ensuring thread-safe network operations without manual locking.

**In-memory caching:** `MainViewModel` includes a Cache struct with 5-minute TTL. Cache is checked before API calls; force refresh is available.

**Menu bar integration:** `AppDelegate` manages NSStatusItem + NSPopover lifecycle. Uses `.accessory` activation policy (no Dock icon), switches to `.regular` only when Settings window is shown.

### Key Files

- `AppDelegate.swift` - Menu bar setup, popover management, global click monitoring
- `MainViewModel.swift` - Central state management with caching
- `APIService.swift` - Actor-based HTTP client with custom APIError enum
- `LaunchAtLoginManager.swift` - ServiceManagement integration for auto-launch

## Configuration

- **Info.plist:** `LSUIElement=true` hides app from Dock
- **Entitlements:** App sandbox enabled + network client access
- **project.yml:** XcodeGen configuration (bundle ID: `com.example.MacAppTemplate`)

## Git Hooks

Husky enforces conventional commits:

- `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`
- Example: `feat(settings): add auto-launch toggle`

Prettier runs on staged `*.{js,json,md}` files via lint-staged.
