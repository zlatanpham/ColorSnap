import SwiftUI

struct ItemRowView: View {
    let item: Item
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon placeholder
            Image(systemName: "doc.text")
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                if !item.displaySubtitle.isEmpty {
                    Text(item.displaySubtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Timestamp
            if let formattedDate = item.formattedDate {
                Text(formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // Handle item tap - customize as needed
            print("Tapped: \(item.title)")
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(Item.samples) { item in
            ItemRowView(item: item)
            Divider()
        }
    }
    .frame(width: 350)
}
