import Foundation

final class FavoritesStorage {
    static let shared = FavoritesStorage()
    private let defaults = UserDefaults.standard
    private enum Key {
        static let driver = "favorite_driver_id"
        static let team = "favorite_team_id"
        static let refresh = "auto_refresh_live"
    }

    var favoriteDriverId: String? {
        get { defaults.string(forKey: Key.driver) }
        set { defaults.set(newValue, forKey: Key.driver) }
    }

    var favoriteTeamId: String? {
        get { defaults.string(forKey: Key.team) }
        set { defaults.set(newValue, forKey: Key.team) }
    }

    var autoRefreshLive: Bool {
        get { defaults.object(forKey: Key.refresh) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.refresh) }
    }

    func reset() {
        [Key.driver, Key.team].forEach(defaults.removeObject(forKey:))
    }
}
