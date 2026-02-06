import AppKit
import Combine
import KeyboardShortcuts
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static private(set) var shared: AppDelegate?

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var settingsWindow: NSWindow?
    private var eventMonitor: Any?
    private let clipboardMonitor = ClipboardMonitorService()
    private var cancellables = Set<AnyCancellable>()
    private var appearanceObservation: NSKeyValueObservation?
    let viewModel = ColorPickerViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        setupStatusItem()
        setupPopover()
        setupEventMonitor()
        setupClipboardMonitor()
        setupGlobalShortcut()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "eyedropper", accessibilityDescription: "ColorSnap")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 480)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(viewModel)
        )
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    private func setupClipboardMonitor() {
        clipboardMonitor.startMonitoring()

        clipboardMonitor.$clipboardColor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] color in
                self?.updateStatusBarIcon(clipboardColor: color)
            }
            .store(in: &cancellables)

        // Observe appearance changes for light/dark mode
        if let button = statusItem?.button {
            appearanceObservation = button.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
                Task { @MainActor in
                    self?.updateStatusBarIcon(clipboardColor: self?.clipboardMonitor.clipboardColor)
                }
            }
        }
    }

    private func setupGlobalShortcut() {
        KeyboardShortcuts.onKeyUp(for: .pickColor) { [weak self] in
            Task { @MainActor in
                await self?.viewModel.pickColor()
            }
        }
    }

    private func updateStatusBarIcon(clipboardColor: NSColor?) {
        guard let button = statusItem?.button else { return }

        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        guard let eyedropperImage = NSImage(systemSymbolName: "eyedropper", accessibilityDescription: "ColorSnap")?
            .withSymbolConfiguration(config) else { return }

        guard let clipboardColor = clipboardColor else {
            // No color in clipboard — plain template eyedropper
            button.image = eyedropperImage
            button.image?.isTemplate = true
            return
        }

        // Composite: eyedropper with color dot overlaid at bottom-right
        // Keep the same image size so the status item width never changes
        let size = eyedropperImage.size
        let dotSize: CGFloat = 7
        let dotInset: CGFloat = 0 // flush with bottom-right corner

        let compositeImage = NSImage(size: size, flipped: false) { _ in
            // Determine if we're in dark mode
            let isDark = button.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let tintColor: NSColor = isDark ? .white : .black

            // Draw tinted eyedropper at full size
            let tintedEyedropper = eyedropperImage.tinted(with: tintColor)
            tintedEyedropper.draw(in: NSRect(origin: .zero, size: size))

            // Draw color dot at bottom-right corner
            let dotRect = NSRect(
                x: size.width - dotSize - dotInset,
                y: dotInset,
                width: dotSize,
                height: dotSize
            )
            let dotPath = NSBezierPath(ovalIn: dotRect)
            clipboardColor.setFill()
            dotPath.fill()

            // Border for visibility against any background
            NSColor.gray.withAlphaComponent(0.6).setStroke()
            dotPath.lineWidth = 0.5
            dotPath.stroke()

            return true
        }

        compositeImage.isTemplate = false
        button.image = compositeImage
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func showSettings() {
        popover?.close()
        openSettingsWindow()
    }

    private func openSettingsWindow() {
        if let settingsWindow = settingsWindow {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Settings"
        window.styleMask = [.titled, .closable]
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        self.settingsWindow = window

        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        settingsWindow = nil
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        clipboardMonitor.stopMonitoring()
        cancellables.removeAll()
        appearanceObservation?.invalidate()
    }
}

// MARK: - NSImage Tinting Helper

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
}
