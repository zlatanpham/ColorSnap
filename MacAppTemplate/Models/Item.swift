import Foundation

/// Sample model placeholder - replace with your actual data model
struct Item: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let createdAt: Date?

    init(id: String = UUID().uuidString, title: String, subtitle: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    var displayTitle: String {
        title.isEmpty ? "Untitled" : title
    }

    var displaySubtitle: String {
        subtitle ?? ""
    }

    var formattedDate: String? {
        guard let date = createdAt else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Sample Data

extension Item {
    static let samples: [Item] = [
        Item(title: "First Item", subtitle: "This is a sample item", createdAt: Date()),
        Item(title: "Second Item", subtitle: "Another sample", createdAt: Date().addingTimeInterval(-3600)),
        Item(title: "Third Item", subtitle: nil, createdAt: Date().addingTimeInterval(-86400))
    ]
}
