import AppKit

extension NSColor {
    func formatted(as format: ColorFormat) -> String {
        let srgb = usingColorSpace(.sRGB) ?? self

        switch format {
        case .hex:
            let r = Int(round(srgb.redComponent * 255))
            let g = Int(round(srgb.greenComponent * 255))
            let b = Int(round(srgb.blueComponent * 255))
            return String(format: "#%02X%02X%02X", r, g, b)

        case .rgb:
            let r = Int(round(srgb.redComponent * 255))
            let g = Int(round(srgb.greenComponent * 255))
            let b = Int(round(srgb.blueComponent * 255))
            return "rgb(\(r), \(g), \(b))"

        case .hsl:
            let (h, s, l) = rgbToHSL(
                r: srgb.redComponent,
                g: srgb.greenComponent,
                b: srgb.blueComponent
            )
            return "hsl(\(Int(round(h))), \(Int(round(s)))%, \(Int(round(l)))%)"

        case .hsb:
            let h = Int(round(srgb.hueComponent * 360))
            let s = Int(round(srgb.saturationComponent * 100))
            let b = Int(round(srgb.brightnessComponent * 100))
            return "hsb(\(h), \(s)%, \(b)%)"
        }
    }

    private func rgbToHSL(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, l: CGFloat) {
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        let l = (maxC + minC) / 2.0

        guard delta > 0 else {
            return (0, 0, l * 100)
        }

        let s: CGFloat
        if l < 0.5 {
            s = delta / (maxC + minC)
        } else {
            s = delta / (2.0 - maxC - minC)
        }

        var h: CGFloat
        if maxC == r {
            h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
        } else if maxC == g {
            h = (b - r) / delta + 2
        } else {
            h = (r - g) / delta + 4
        }

        h *= 60
        if h < 0 { h += 360 }

        return (h, s * 100, l * 100)
    }
}
