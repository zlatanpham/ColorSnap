import Foundation

@MainActor
class MainViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var error: String?

    private let apiService = APIService.shared
    private var cache = Cache()

    // MARK: - Cache

    private struct Cache {
        var items: [Item]?
        var lastFetch: Date?
        let ttl: TimeInterval = 300 // 5 minutes

        var isValid: Bool {
            guard let lastFetch = lastFetch else { return false }
            return Date().timeIntervalSince(lastFetch) < ttl
        }

        mutating func update(items: [Item]) {
            self.items = items
            self.lastFetch = Date()
        }

        mutating func invalidate() {
            self.items = nil
            self.lastFetch = nil
        }
    }

    // MARK: - Public Methods

    func loadItems(forceRefresh: Bool = false) async {
        // Return cached data if valid
        if !forceRefresh, cache.isValid, let cachedItems = cache.items {
            items = cachedItems
            return
        }

        isLoading = true
        error = nil

        do {
            let fetchedItems = try await apiService.fetchItems()
            items = fetchedItems
            cache.update(items: fetchedItems)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadItems(forceRefresh: true)
    }

    func clearCache() {
        cache.invalidate()
    }
}
