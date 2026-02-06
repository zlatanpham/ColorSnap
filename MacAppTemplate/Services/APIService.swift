import Foundation

/// Actor-based API service for thread-safe network operations
actor APIService {
    static let shared = APIService()

    private let baseURL = "https://api.example.com"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public Methods

    /// Fetch items from API - replace with your actual endpoint
    func fetchItems() async throws -> [Item] {
        // TODO: Replace with actual API call
        // Example implementation:
        // let url = URL(string: "\(baseURL)/items")!
        // let (data, response) = try await session.data(from: url)
        // guard let httpResponse = response as? HTTPURLResponse,
        //       (200...299).contains(httpResponse.statusCode) else {
        //     throw APIError.invalidResponse
        // }
        // return try JSONDecoder().decode([Item].self, from: data)

        // Placeholder: Return sample data after simulated delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return Item.samples
    }

    /// Generic fetch method template
    func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
