import SwiftUI

struct ColorHistoryView: View {
    let colors: [PickedColor]
    let selectedColor: PickedColor?
    let onSelect: (PickedColor) -> Void
    let onDelete: (PickedColor) -> Void

    var body: some View {
        Group {
            if colors.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "eyedropper")
                .font(.system(size: 24))
                .foregroundColor(.secondary)

            Text("No Colors Yet")
                .font(.system(size: 13, weight: .medium))

            Text("Click \"Pick\" to sample a color")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(colors) { color in
                    ColorRowView(
                        color: color,
                        isSelected: color.id == selectedColor?.id,
                        onSelect: { onSelect(color) },
                        onDelete: { onDelete(color) }
                    )
                    Divider()
                        .padding(.leading, 36)
                }
            }
        }
    }
}
