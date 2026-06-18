import Foundation

enum DateFormatterHelper {
    static var apiToday: String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date()) }
    static func pretty(_ value: String) -> String {
        let input = DateFormatter(); input.dateFormat = "yyyy-MM-dd"
        guard let date = input.date(from: value) else { return value }
        let out = DateFormatter(); out.dateStyle = .medium; out.timeStyle = .none
        return out.string(from: date)
    }
}
