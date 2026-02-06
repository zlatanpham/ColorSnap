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
                    formatRow(format)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func formatRow(_ format: ColorFormat) -> some View {
        HStack(spacing: 8) {
            Text(format.rawValue)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)

            Text(color.formatted(format))
                .font(.system(size: 12, design: .monospaced))
                .lineLimit(1)
                .textSelection(.enabled)

            Spacer()

            Button(action: { onCopy(format) }) {
                Image(systemName: copiedFormat == format ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(copiedFormat == format ? .green : .secondary)
            }
            .buttonStyle(.borderless)
            .help("Copy \(format.rawValue)")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(4)
    }
}
