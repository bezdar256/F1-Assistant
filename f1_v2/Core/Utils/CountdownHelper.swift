import Foundation

enum CountdownHelper {
    static func text(until date: Date?) -> String {
        guard let date else { return "Date TBA" }
        let diff = max(0, Int(date.timeIntervalSince(Date())))
        let days = diff / 86400
        let hours = (diff % 86400) / 3600
        let minutes = (diff % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
