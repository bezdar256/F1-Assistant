import Foundation

struct OpenF1Session: Codable {
    let sessionKey: Int
    let meetingKey: Int?
    let location: String?
    let countryName: String?
    let circuitShortName: String?
    let sessionName: String?
    let sessionType: String?
    let dateStart: String?
    let dateEnd: String?
    let year: Int?
}

struct OpenF1Driver: Codable {
    let driverNumber: Int
    let broadcastName: String?
    let fullName: String?
    let nameAcronym: String?
    let teamName: String?
    let teamColour: String?
    let firstName: String?
    let lastName: String?
    let headshotUrl: String?
}

struct OpenF1Position: Codable { let date: String?; let driverNumber: Int; let position: Int; let sessionKey: Int? }
struct OpenF1Interval: Codable { let date: String?; let driverNumber: Int; let gapToLeader: DoubleOrString?; let interval: DoubleOrString? }
struct OpenF1Lap: Codable { let driverNumber: Int; let lapNumber: Int?; let lapDuration: Double?; let durationSector1: Double?; let durationSector2: Double?; let durationSector3: Double? }
struct OpenF1PitStop: Codable { let driverNumber: Int; let lapNumber: Int?; let pitDuration: Double?; let date: String? }
struct OpenF1Stint: Codable { let driverNumber: Int; let compound: String?; let lapStart: Int?; let lapEnd: Int?; let stintNumber: Int?; let tyreAgeAtStart: Int? }
struct OpenF1Weather: Codable { let airTemperature: Double?; let trackTemperature: Double?; let rainfall: Int?; let humidity: Double?; let windSpeed: Double?; let date: String? }
struct OpenF1RaceControl: Codable { let date: String?; let category: String?; let message: String?; let flag: String?; let driverNumber: Int?; let lapNumber: Int? }

enum DoubleOrString: Codable, CustomStringConvertible {
    case double(Double)
    case string(String)
    case none

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .none }
        else if let d = try? c.decode(Double.self) { self = .double(d) }
        else if let s = try? c.decode(String.self) { self = .string(s) }
        else { self = .none }
    }

    func encode(to encoder: Encoder) throws {}
    var description: String {
        switch self { case .double(let d): return String(format: "%.3f", d); case .string(let s): return s; case .none: return "—" }
    }
}
