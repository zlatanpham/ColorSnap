# MacAppTemplate

A macOS menu bar app boilerplate with SwiftUI, MVVM architecture, and actor-based concurrency.

## Features

- **Menu Bar Only** - Runs as a status bar app (no Dock icon)
- **Popover Interface** - Click-to-toggle popover window
- **Settings Window** - Separate settings with Launch at Login support
- **MVVM Architecture** - Clean separation of concerns
- **Actor-based Services** - Thread-safe API layer
- **In-memory Caching** - With TTL support

## Requirements

- macOS 14.0+
- Xcode 15.0+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Quick Start

```bash
# Generate Xcode project and open
make open

# Or step by step:
xcodegen generate
open MacAppTemplate.xcodeproj
```

Build and run with `Cmd+R` in Xcode.

## Project Structure

```
MacAppTemplate/
├── MacAppTemplateApp.swift    # @main entry point
├── AppDelegate.swift          # Menu bar & popover setup
├── ContentView.swift          # Main popover UI
├── Models/
│   └── Item.swift             # Sample model
├── Views/
│   ├── ItemListView.swift     # List container
│   ├── ItemRowView.swift      # Row component
│   └── SettingsView.swift     # Settings window
├── ViewModels/
│   └── MainViewModel.swift    # State manager
├── Services/
│   ├── APIService.swift       # Actor-based API client
│   └── LaunchAtLoginManager.swift
└── Assets.xcassets/
```

## Customization

### Change the Menu Bar Icon

In `AppDelegate.swift`, modify the system symbol:

```swift
button.image = NSImage(systemSymbolName: "your.icon.name", accessibilityDescription: "App")
```

### Add Your API

Replace the placeholder in `APIService.swift`:

```swift
func fetchItems() async throws -> [Item] {
    let url = URL(string: "\(baseURL)/your-endpoint")!
    let (data, _) = try await session.data(from: url)
    return try JSONDecoder().decode([Item].self, from: data)
}
```

### Update the Model

Replace `Item.swift` with your data model:

```swift
struct YourModel: Identifiable, Codable {
    let id: String
    // Your properties
}
```

## Build Commands

```bash
make generate  # Generate Xcode project
make open      # Generate and open in Xcode
make build     # Build release
make test      # Run tests
make clean     # Clean build artifacts
make archive   # Create release archive
make dmg       # Create DMG installer
```

## Key Patterns

### Menu Bar Setup

The app uses `LSUIElement=true` in Info.plist to hide from Dock. The `AppDelegate` manages:
- `NSStatusItem` for menu bar icon
- `NSPopover` for the main interface
- Event monitor for click-outside dismissal

### Settings Window

Settings uses SwiftUI's `Settings` scene and temporarily switches activation policy to show in Dock while settings are open.

### Caching

`MainViewModel` includes a cache pattern with TTL:

```swift
private struct Cache {
    var items: [Item]?
    var lastFetch: Date?
    let ttl: TimeInterval = 300 // 5 minutes
}
```

## License

MIT
