import AppKit
import Combine

@MainActor
class ClipboardMonitorService: ObservableObject {
    @Published var clipboardColor: NSColor?

    private var timer: Timer?
    private var lastChangeCount: Int = 0

    func startMonitoring() {
        checkClipboard()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkClipboard()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard let string = pasteboard.string(forType: .string) else {
            clipboardColor = nil
            return
        }

        clipboardColor = NSColor.fromColorString(string)
    }
}
