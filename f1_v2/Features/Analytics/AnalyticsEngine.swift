import Foundation

struct AnalyticsEngine {
    static func mostImprovedDriver() -> LocalDriver { FallbackData.drivers.min { ($0.lastResults.last ?? 10) < ($1.lastResults.last ?? 10) } ?? FallbackData.drivers[0] }
}
