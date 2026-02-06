import Foundation

enum ColorFormat: String, CaseIterable, Codable, Identifiable {
    case hex = "HEX"
    case rgb = "RGB"
    case hsl = "HSL"
    case hsb = "HSB"

    var id: String { rawValue }
}
