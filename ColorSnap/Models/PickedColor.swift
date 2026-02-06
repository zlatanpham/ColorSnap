import AppKit
import Foundation

struct PickedColor: Identifiable, Codable, Hashable {
    let id: String
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    let pickedAt: Date

    init(nsColor: NSColor) {
        let srgb = nsColor.usingColorSpace(.sRGB) ?? nsColor
        self.id = UUID().uuidString
        self.red = srgb.redComponent
        self.green = srgb.greenComponent
        self.blue = srgb.blueComponent
        self.alpha = srgb.alphaComponent
        self.pickedAt = Date()
    }

    var nsColor: NSColor {
        NSColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
    }

    func formatted(_ format: ColorFormat) -> String {
        nsColor.formatted(as: format)
    }

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: pickedAt, relativeTo: Date())
    }
}
