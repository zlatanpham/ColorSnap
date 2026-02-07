import SwiftUI

struct ColorPreviewView: View {
    let color: PickedColor
    let copiedFormat: ColorFormat?
    let onCopy: (ColorFormat) -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Color swatch
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: color.nsColor))
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                )

            // Format rows
            VStack(spacing: 4) {
                ForEach(ColorFormat.allCases) { format in
                    FormatRowView(
                        format: format,
                        formattedValue: color.formatted(format),
                        isCopied: copiedFormat == format,
                        onCopy: { onCopy(format) }
                    )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct FormatRowView: View {
    let format: ColorFormat
    let formattedValue: String
    let isCopied: Bool
    let onCopy: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Text(format.rawValue)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)

            Text(formattedValue)
                .font(.system(size: 12, design: .monospaced))
                .lineLimit(1)

            Spacer()

            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 11))
                .foregroundColor(isCopied ? .green : .secondary)
                .frame(width: 16, height: 16)
                .opacity(isHovered || isCopied ? 1 : 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { onCopy() }
        .onHover { isHovered = $0 }
        .background(isHovered ? Color.primary.opacity(0.06) : Color.primary.opacity(0.03))
        .cornerRadius(4)
        .help("Copy \(format.rawValue)")
    }
}
