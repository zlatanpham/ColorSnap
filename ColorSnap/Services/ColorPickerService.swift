import AppKit

actor ColorPickerService {
    static let shared = ColorPickerService()

    private init() {}

    @MainActor
    func pickColor() async -> NSColor? {
        await withCheckedContinuation { continuation in
            let sampler = NSColorSampler()
            sampler.show { selectedColor in
                continuation.resume(returning: selectedColor)
            }
        }
    }
}
