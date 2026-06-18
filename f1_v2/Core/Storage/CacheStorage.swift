import Foundation

final class CacheStorage {
    static let shared = CacheStorage()
    private let defaults = UserDefaults.standard
    func save<T: Encodable>(_ value: T, for key: String) { if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) } }
    func load<T: Decodable>(_ type: T.Type, for key: String) -> T? { guard let data = defaults.data(forKey: key) else { return nil }; return try? JSONDecoder().decode(T.self, from: data) }
}
