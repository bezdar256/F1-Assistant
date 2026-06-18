import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL, invalidResponse, statusCode(Int), decodingError(Error), missingAPIKey, rateLimited
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .statusCode(let code): return "Server returned status code \(code)"
        case .decodingError: return "Could not decode server data"
        case .missingAPIKey: return "API key is missing"
        case .rateLimited: return "API rate limit reached"
        }
    }
}
