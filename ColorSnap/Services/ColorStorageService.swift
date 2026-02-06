import Foundation

actor ColorStorageService {
    static let shared = ColorStorageService()

    private let storageKey = "colorHistory"
    private let maxColors = 100

    private init() {}

    func loadColors() -> [PickedColor] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return (try? JSONDecoder().decode([PickedColor].self, from: data)) ?? []
    }

    func saveColor(_ color: PickedColor) {
        var colors = loadColors()
        colors.insert(color, at: 0)
        if colors.count > maxColors {
            colors = Array(colors.prefix(maxColors))
        }
        persist(colors)
    }

    func removeColor(id: String) {
        var colors = loadColors()
        colors.removeAll { $0.id == id }
        persist(colors)
    }

    func clearAll() {
        persist([])
    }

    private func persist(_ colors: [PickedColor]) {
        guard let data = try? JSONEncoder().encode(colors) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
