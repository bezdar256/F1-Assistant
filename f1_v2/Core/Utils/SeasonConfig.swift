import Foundation

enum SeasonConfig {
    static let currentSeason = 2026
    static let previousSeasons = [2025, 2024, 2023]

    static var seasonTitle: String {
        "F1 \(currentSeason) Season"
    }
}
