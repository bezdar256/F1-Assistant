import Foundation

struct RaceScheduleResponse: Codable {
    let mrData: MRData
    enum CodingKeys: String, CodingKey { case mrData = "MRData" }
}

struct MRData: Codable {
    let raceTable: RaceTable?
    let standingsTable: StandingsTable?
    enum CodingKeys: String, CodingKey { case raceTable = "RaceTable"; case standingsTable = "StandingsTable" }
}

struct RaceTable: Codable { let season: String?; let round: String?; let races: [Race]
    enum CodingKeys: String, CodingKey { case season, round; case races = "Races" }
}

struct Race: Codable {
    let season: String
    let round: String
    let url: String?
    let raceName: String
    let circuit: Circuit
    let date: String
    let time: String?
    let firstPractice: SessionTime?
    let secondPractice: SessionTime?
    let thirdPractice: SessionTime?
    let qualifying: SessionTime?
    let sprint: SessionTime?
    let results: [RaceResult]?
    enum CodingKeys: String, CodingKey {
        case season, round, url, raceName, date, time
        case circuit = "Circuit"
        case firstPractice = "FirstPractice"
        case secondPractice = "SecondPractice"
        case thirdPractice = "ThirdPractice"
        case qualifying = "Qualifying"
        case sprint = "Sprint"
        case results = "Results"
    }
}

struct SessionTime: Codable { let date: String; let time: String? }
struct Circuit: Codable { let circuitId: String; let url: String?; let circuitName: String; let location: Location
    enum CodingKeys: String, CodingKey { case circuitId, url, circuitName; case location = "Location" }
}
struct Location: Codable { let lat: String?; let long: String?; let locality: String; let country: String }

struct DriverStandingsResponse: Codable {
    let mrData: MRData
    enum CodingKeys: String, CodingKey { case mrData = "MRData" }
}
struct ConstructorStandingsResponse: Codable {
    let mrData: MRData
    enum CodingKeys: String, CodingKey { case mrData = "MRData" }
}
struct StandingsTable: Codable { let season: String?; let round: String?; let standingsLists: [StandingsList]
    enum CodingKeys: String, CodingKey { case season, round; case standingsLists = "StandingsLists" }
}
struct StandingsList: Codable {
    let season: String
    let round: String?
    let driverStandings: [DriverStanding]?
    let constructorStandings: [ConstructorStanding]?
    enum CodingKeys: String, CodingKey { case season, round; case driverStandings = "DriverStandings"; case constructorStandings = "ConstructorStandings" }
}
struct DriverStanding: Codable {
    let position: String
    let points: String
    let wins: String
    let driver: Driver
    let constructors: [Constructor]
    enum CodingKeys: String, CodingKey { case position, points, wins; case driver = "Driver"; case constructors = "Constructors" }
}
struct ConstructorStanding: Codable {
    let position: String
    let points: String
    let wins: String
    let constructor: Constructor
    enum CodingKeys: String, CodingKey { case position, points, wins; case constructor = "Constructor" }
}
struct Driver: Codable {
    let driverId: String
    let permanentNumber: String?
    let code: String?
    let url: String?
    let givenName: String
    let familyName: String
    let dateOfBirth: String?
    let nationality: String
    var fullName: String { "\(givenName) \(familyName)" }
}
struct Constructor: Codable { let constructorId: String; let url: String?; let name: String; let nationality: String }

struct RaceResultsResponse: Codable {
    let mrData: MRDataResults
    enum CodingKeys: String, CodingKey { case mrData = "MRData" }
}
struct MRDataResults: Codable { let raceTable: RaceTableResults
    enum CodingKeys: String, CodingKey { case raceTable = "RaceTable" }
}
struct RaceTableResults: Codable { let races: [Race]
    enum CodingKeys: String, CodingKey { case races = "Races" }
}
struct RaceResult: Codable {
    let number: String
    let position: String
    let positionText: String?
    let points: String
    let driver: Driver
    let constructor: Constructor
    let grid: String?
    let laps: String?
    let status: String
    let time: ResultTime?
    let fastestLap: FastestLap?
    enum CodingKeys: String, CodingKey { case number, position, positionText, points, grid, laps, status; case driver = "Driver"; case constructor = "Constructor"; case time = "Time"; case fastestLap = "FastestLap" }
}
struct ResultTime: Codable { let millis: String?; let time: String }
struct FastestLap: Codable { let rank: String?; let lap: String?; let time: LapTime?
    enum CodingKeys: String, CodingKey { case rank, lap; case time = "Time" }
}
struct LapTime: Codable { let time: String }

struct QualifyingResponse: Codable {
    let mrData: MRDataQualifying
    enum CodingKeys: String, CodingKey { case mrData = "MRData" }
}
struct MRDataQualifying: Codable { let raceTable: QualifyingRaceTable
    enum CodingKeys: String, CodingKey { case raceTable = "RaceTable" }
}
struct QualifyingRaceTable: Codable { let races: [QualifyingRace]
    enum CodingKeys: String, CodingKey { case races = "Races" }
}
struct QualifyingRace: Codable { let qualifyingResults: [QualifyingResult]
    enum CodingKeys: String, CodingKey { case qualifyingResults = "QualifyingResults" }
}
struct QualifyingResult: Codable {
    let number: String
    let position: String
    let driver: Driver
    let constructor: Constructor
    let q1: String?
    let q2: String?
    let q3: String?
    enum CodingKeys: String, CodingKey { case number, position, q1 = "Q1", q2 = "Q2", q3 = "Q3"; case driver = "Driver"; case constructor = "Constructor" }
}
