import Foundation

enum APIEndpoint {
    static let jolpicaBase = "https://api.jolpi.ca/ergast/f1/"
    static let openF1Base = "https://api.openf1.org/v1/"

    static func jolpica(_ path: String) throws -> URL {
        guard let url = URL(string: jolpicaBase + path) else { throw NetworkError.invalidURL }
        return url
    }

    static func openF1(_ path: String, query: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: openF1Base + path) else { throw NetworkError.invalidURL }
        components.queryItems = query.isEmpty ? nil : query
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    static func weather(lat: Double, lon: Double) throws -> URL {
        guard !APIKeys.openWeather.isEmpty else { throw NetworkError.missingAPIKey }
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather") else { throw NetworkError.invalidURL }
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: APIKeys.openWeather),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru")
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    static func news() throws -> URL {
        guard !APIKeys.newsAPI.isEmpty else { throw NetworkError.missingAPIKey }
        guard var components = URLComponents(string: "https://newsapi.org/v2/everything") else { throw NetworkError.invalidURL }
        components.queryItems = [
            URLQueryItem(name: "q", value: "formula 1 OR f1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "apiKey", value: APIKeys.newsAPI)
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }
}
