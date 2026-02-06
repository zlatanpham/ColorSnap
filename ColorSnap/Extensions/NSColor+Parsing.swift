import AppKit

extension NSColor {
    /// Parses a color string (HEX, RGB, HSL, HSB) and returns an NSColor.
    /// Matches the output formats of `NSColor.formatted(as:)`.
    static func fromColorString(_ string: String) -> NSColor? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard trimmed.count <= 30 else { return nil }

        if let color = parseHex(trimmed) { return color }
        if let color = parseRGB(trimmed) { return color }
        if let color = parseHSL(trimmed) { return color }
        if let color = parseHSB(trimmed) { return color }
        return nil
    }

    // MARK: - HEX: #RRGGBB

    private static func parseHex(_ string: String) -> NSColor? {
        guard string.hasPrefix("#"), string.count == 7 else { return nil }
        let hex = String(string.dropFirst())
        guard let value = UInt64(hex, radix: 16) else { return nil }
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        return NSColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
    }

    // MARK: - RGB: rgb(r, g, b)

    private static func parseRGB(_ string: String) -> NSColor? {
        guard let match = string.wholeMatch(of: /rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)/) else {
            return nil
        }
        guard let r = Int(match.1), let g = Int(match.2), let b = Int(match.3),
              r <= 255, g <= 255, b <= 255 else { return nil }
        return NSColor(srgbRed: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }

    // MARK: - HSL: hsl(h, s%, l%)

    private static func parseHSL(_ string: String) -> NSColor? {
        guard let match = string.wholeMatch(of: /hsl\(\s*(\d{1,3})\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%\s*\)/) else {
            return nil
        }
        guard let h = Int(match.1), let s = Int(match.2), let l = Int(match.3),
              h <= 360, s <= 100, l <= 100 else { return nil }

        let hNorm = CGFloat(h) / 360.0
        let sNorm = CGFloat(s) / 100.0
        let lNorm = CGFloat(l) / 100.0

        // HSL to RGB conversion
        let (r, g, b) = hslToRGB(h: hNorm, s: sNorm, l: lNorm)
        return NSColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
    }

    private static func hslToRGB(h: CGFloat, s: CGFloat, l: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
        guard s > 0 else { return (l, l, l) }

        let c = (1.0 - abs(2.0 * l - 1.0)) * s
        let x = c * (1.0 - abs((h * 6.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = l - c / 2.0

        let (r1, g1, b1): (CGFloat, CGFloat, CGFloat)
        let hSector = h * 6.0
        switch hSector {
        case 0..<1: (r1, g1, b1) = (c, x, 0)
        case 1..<2: (r1, g1, b1) = (x, c, 0)
        case 2..<3: (r1, g1, b1) = (0, c, x)
        case 3..<4: (r1, g1, b1) = (0, x, c)
        case 4..<5: (r1, g1, b1) = (x, 0, c)
        default:    (r1, g1, b1) = (c, 0, x)
        }

        return (r1 + m, g1 + m, b1 + m)
    }

    // MARK: - HSB: hsb(h, s%, b%)

    private static func parseHSB(_ string: String) -> NSColor? {
        guard let match = string.wholeMatch(of: /hsb\(\s*(\d{1,3})\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%\s*\)/) else {
            return nil
        }
        guard let h = Int(match.1), let s = Int(match.2), let b = Int(match.3),
              h <= 360, s <= 100, b <= 100 else { return nil }
        return NSColor(
            hue: CGFloat(h) / 360.0,
            saturation: CGFloat(s) / 100.0,
            brightness: CGFloat(b) / 100.0,
            alpha: 1.0
        )
    }
}
