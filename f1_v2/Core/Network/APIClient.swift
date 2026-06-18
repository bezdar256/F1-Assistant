import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func request<T: Decodable>(_ url: URL, timeout: TimeInterval = 10) async throws -> T {
        let data = try await data(url, timeout: timeout)
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func data(_ url: URL, timeout: TimeInterval = 10) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("F1Assistant/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        if http.statusCode == 429 { throw NetworkError.rateLimited }
        guard 200...299 ~= http.statusCode else { throw NetworkError.statusCode(http.statusCode) }
        return data
    }
}
