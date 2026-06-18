import UIKit

struct LocalDriver {
    let id: String, name: String, code: String, number: String, teamId: String, team: String, nationality: String, imageName: String
    let position: Int, points: Double, wins: Int, podiums: Int, averageFinish: Double, lastResults: [Int]
}

struct LocalTeam {
    let id: String, name: String, drivers: [String], logoName: String, carImageName: String, colorHex: String
    let position: Int, points: Double, wins: Int, podiums: Int, trend: [Double]
}

struct LocalCircuit {
    let id: String, name: String, country: String, city: String, photoName: String, trackImageName: String
    let length: String, turns: Int, laps: Int, distance: String, lapRecord: String, drs: String, previousWinner: String
}

struct LocalRace {
    let round: Int, title: String, date: String, circuitId: String, status: String
    let sessions: [(String, String, String)]
}

struct LiveRow {
    let position: Int, driver: String, code: String, team: String, gap: String, tyre: String, pitStops: Int, interval: Double
}

struct PitFeedItem { let lap: Int, driver: String, duration: String, change: String }
struct RaceControlItem { let lap: Int, title: String, message: String, color: UIColor }
struct LocalNews: Codable { let title: String, source: String, date: String, summary: String, imageName: String, url: String }

enum FallbackData {
    static let drivers: [LocalDriver] = [
        .init(id:"verstappen", name:"Max Verstappen", code:"VER", number:"1", teamId:"redbull", team:"Red Bull Racing", nationality:"Netherlands", imageName:"verstappen", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"norris", name:"Lando Norris", code:"NOR", number:"4", teamId:"mclaren", team:"McLaren", nationality:"United Kingdom", imageName:"norris", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"leclerc", name:"Charles Leclerc", code:"LEC", number:"16", teamId:"ferrari", team:"Ferrari", nationality:"Monaco", imageName:"leclerc", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"piastri", name:"Oscar Piastri", code:"PIA", number:"81", teamId:"mclaren", team:"McLaren", nationality:"Australia", imageName:"piastri", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"sainz", name:"Carlos Sainz", code:"SAI", number:"55", teamId:"williams", team:"Williams", nationality:"Spain", imageName:"sainz", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"hamilton", name:"Lewis Hamilton", code:"HAM", number:"44", teamId:"ferrari", team:"Ferrari", nationality:"United Kingdom", imageName:"hamilton", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"russell", name:"George Russell", code:"RUS", number:"63", teamId:"mercedes", team:"Mercedes", nationality:"United Kingdom", imageName:"russell", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[]),
        .init(id:"alonso", name:"Fernando Alonso", code:"ALO", number:"14", teamId:"aston", team:"Aston Martin", nationality:"Spain", imageName:"alonso", position:0, points:0, wins:0, podiums:0, averageFinish:0, lastResults:[])
    ]


    static let teams: [LocalTeam] = [
        .init(id:"mclaren", name:"McLaren", drivers:["Lando Norris","Oscar Piastri"], logoName:"mclaren_logo", carImageName:"mclaren_car", colorHex:"#FF8700", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"redbull", name:"Red Bull Racing", drivers:["Max Verstappen","Yuki Tsunoda"], logoName:"redbull_logo", carImageName:"redbull_car", colorHex:"#1E41FF", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"ferrari", name:"Ferrari", drivers:["Charles Leclerc","Lewis Hamilton"], logoName:"ferrari_logo", carImageName:"ferrari_car", colorHex:"#DC0000", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"mercedes", name:"Mercedes", drivers:["George Russell","Kimi Antonelli"], logoName:"mercedes_logo", carImageName:"mercedes_car", colorHex:"#00D2BE", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"aston", name:"Aston Martin", drivers:["Fernando Alonso","Lance Stroll"], logoName:"aston_logo", carImageName:"aston_car", colorHex:"#006F62", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"alpine", name:"Alpine", drivers:[], logoName:"alpine_logo", carImageName:"alpine_car", colorHex:"#0090FF", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"haas", name:"Haas", drivers:[], logoName:"haas_logo", carImageName:"haas_car", colorHex:"#B6BABD", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"williams", name:"Williams", drivers:[], logoName:"williams_logo", carImageName:"williams_car", colorHex:"#00A3E0", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"racingbulls", name:"Racing Bulls", drivers:[], logoName:"racingbulls_logo", carImageName:"racingbulls_car", colorHex:"#6692FF", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"audi", name:"Audi", drivers:[], logoName:"audi_logo", carImageName:"audi_car", colorHex:"#00E701", position:0, points:0, wins:0, podiums:0, trend:[]),
        .init(id:"cadillac", name:"Cadillac", drivers:[], logoName:"cadillac_logo", carImageName:"cadillac_car", colorHex:"#B9975B", position:0, points:0, wins:0, podiums:0, trend:[])
    ]

    static let circuits: [LocalCircuit] = [
        .init(id:"bahrain", name:"Bahrain International Circuit", country:"Bahrain", city:"Sakhir", photoName:"bahrain_photo", trackImageName:"bahrain_track", length:"5.412 km", turns:15, laps:57, distance:"308.238 km", lapRecord:"1:31.447", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"jeddah", name:"Jeddah Corniche Circuit", country:"Saudi Arabia", city:"Jeddah", photoName:"jeddah_photo", trackImageName:"jeddah_track", length:"6.174 km", turns:27, laps:50, distance:"308.450 km", lapRecord:"1:30.734", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"albert_park", name:"Melbourne Grand Prix Circuit", country:"Australia", city:"Melbourne", photoName:"albert_park_photo", trackImageName:"albert_park_track", length:"5.278 km", turns:14, laps:58, distance:"306.124 km", lapRecord:"1:19.813", drs:"4 zones", previousWinner:"TBA"),
        .init(id:"suzuka", name:"Suzuka Circuit", country:"Japan", city:"Suzuka", photoName:"suzuka_photo", trackImageName:"suzuka_track", length:"5.807 km", turns:18, laps:53, distance:"307.471 km", lapRecord:"1:30.983", drs:"1 zone", previousWinner:"TBA"),
        .init(id:"shanghai", name:"Shanghai International Circuit", country:"China", city:"Shanghai", photoName:"shanghai_photo", trackImageName:"shanghai_track", length:"5.451 km", turns:16, laps:56, distance:"305.066 km", lapRecord:"1:32.238", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"miami", name:"Miami International Autodrome", country:"United States", city:"Miami", photoName:"miami_photo", trackImageName:"miami_track", length:"5.412 km", turns:19, laps:57, distance:"308.326 km", lapRecord:"1:29.708", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"imola", name:"Autodromo Enzo e Dino Ferrari", country:"Italy", city:"Imola", photoName:"imola_photo", trackImageName:"imola_track", length:"4.909 km", turns:19, laps:63, distance:"309.049 km", lapRecord:"1:15.484", drs:"1 zone", previousWinner:"TBA"),
        .init(id:"monaco", name:"Circuit de Monaco", country:"Monaco", city:"Monte Carlo", photoName:"monaco_photo", trackImageName:"monaco_track", length:"3.337 km", turns:19, laps:78, distance:"260.286 km", lapRecord:"1:12.909", drs:"1 zone", previousWinner:"TBA"),
        .init(id:"catalunya", name:"Circuit de Barcelona-Catalunya", country:"Spain", city:"Montmeló", photoName:"catalunya_photo", trackImageName:"catalunya_track", length:"4.657 km", turns:14, laps:66, distance:"307.236 km", lapRecord:"1:16.330", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"villeneuve", name:"Circuit Gilles-Villeneuve", country:"Canada", city:"Montréal", photoName:"villeneuve_photo", trackImageName:"villeneuve_track", length:"4.361 km", turns:14, laps:70, distance:"305.270 km", lapRecord:"1:13.078", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"red_bull_ring", name:"Red Bull Ring", country:"Austria", city:"Spielberg", photoName:"red_bull_ring_photo", trackImageName:"red_bull_ring_track", length:"4.318 km", turns:10, laps:71, distance:"306.452 km", lapRecord:"1:05.619", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"silverstone", name:"Silverstone Circuit", country:"United Kingdom", city:"Silverstone", photoName:"silverstone_photo", trackImageName:"silverstone_track", length:"5.891 km", turns:18, laps:52, distance:"306.198 km", lapRecord:"1:27.097", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"spa", name:"Circuit de Spa-Francorchamps", country:"Belgium", city:"Stavelot", photoName:"spa_photo", trackImageName:"spa_track", length:"7.004 km", turns:19, laps:44, distance:"308.052 km", lapRecord:"1:46.286", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"hungaroring", name:"Hungaroring", country:"Hungary", city:"Mogyoród", photoName:"hungaroring_photo", trackImageName:"hungaroring_track", length:"4.381 km", turns:14, laps:70, distance:"306.630 km", lapRecord:"1:16.627", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"zandvoort", name:"Circuit Zandvoort", country:"Netherlands", city:"Zandvoort", photoName:"zandvoort_photo", trackImageName:"zandvoort_track", length:"4.259 km", turns:14, laps:72, distance:"306.587 km", lapRecord:"1:11.097", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"monza", name:"Autodromo Nazionale Monza", country:"Italy", city:"Monza", photoName:"monza_photo", trackImageName:"monza_track", length:"5.793 km", turns:11, laps:53, distance:"306.720 km", lapRecord:"1:21.046", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"baku", name:"Baku City Circuit", country:"Azerbaijan", city:"Baku", photoName:"baku_photo", trackImageName:"baku_track", length:"6.003 km", turns:20, laps:51, distance:"306.049 km", lapRecord:"1:43.009", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"marina_bay", name:"Marina Bay Street Circuit", country:"Singapore", city:"Singapore", photoName:"marina_bay_photo", trackImageName:"marina_bay_track", length:"4.940 km", turns:19, laps:62, distance:"306.143 km", lapRecord:"1:34.486", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"americas", name:"Circuit of the Americas", country:"United States", city:"Austin", photoName:"americas_photo", trackImageName:"americas_track", length:"5.513 km", turns:20, laps:56, distance:"308.405 km", lapRecord:"1:36.169", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"rodriguez", name:"Autódromo Hermanos Rodríguez", country:"Mexico", city:"Mexico City", photoName:"rodriguez_photo", trackImageName:"rodriguez_track", length:"4.304 km", turns:17, laps:71, distance:"305.354 km", lapRecord:"1:17.774", drs:"3 zones", previousWinner:"TBA"),
        .init(id:"interlagos", name:"Autódromo José Carlos Pace", country:"Brazil", city:"São Paulo", photoName:"interlagos_photo", trackImageName:"interlagos_track", length:"4.309 km", turns:15, laps:71, distance:"305.879 km", lapRecord:"1:10.540", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"vegas", name:"Las Vegas Street Circuit", country:"United States", city:"Las Vegas", photoName:"vegas_photo", trackImageName:"vegas_track", length:"6.201 km", turns:17, laps:50, distance:"309.958 km", lapRecord:"1:35.490", drs:"2 zones", previousWinner:"TBA"),
        .init(id:"losail", name:"Lusail International Circuit", country:"Qatar", city:"Lusail", photoName:"losail_photo", trackImageName:"losail_track", length:"5.419 km", turns:16, laps:57, distance:"308.611 km", lapRecord:"1:24.319", drs:"1 zone", previousWinner:"TBA"),
        .init(id:"yas_marina", name:"Yas Marina Circuit", country:"United Arab Emirates", city:"Abu Dhabi", photoName:"yas_marina_photo", trackImageName:"yas_marina_track", length:"5.281 km", turns:16, laps:58, distance:"306.183 km", lapRecord:"1:26.103", drs:"2 zones", previousWinner:"TBA")
    ]

    static func circuit(for id: String) -> LocalCircuit {
        let key = id.normalizedCircuitKey
        if let direct = circuits.first(where: { $0.id.normalizedCircuitKey == key }) { return direct }
        if key.contains("albertpark") { return circuits.first { $0.id == "albert_park" }! }
        if key.contains("redbull") { return circuits.first { $0.id == "red_bull_ring" }! }
        if key.contains("americas") || key.contains("cota") { return circuits.first { $0.id == "americas" }! }
        if key.contains("marinabay") { return circuits.first { $0.id == "marina_bay" }! }
        if key.contains("yasmine") || key.contains("yasmarina") { return circuits.first { $0.id == "yas_marina" }! }
        if key.contains("interlagos") || key.contains("josecarlospace") { return circuits.first { $0.id == "interlagos" }! }
        if key.contains("rodriguez") || key.contains("mexico") { return circuits.first { $0.id == "rodriguez" }! }
        return LocalCircuit(id: id, name: id.replacingOccurrences(of: "_", with: " ").capitalized, country: "", city: "", photoName: "f1_hero", trackImageName: "map_placeholder", length: "TBA", turns: 0, laps: 0, distance: "TBA", lapRecord: "TBA", drs: "TBA", previousWinner: "TBA")
    }

    static let races: [LocalRace] = [
        .init(round: 1, title: "Season opener", date: "2026-03-01", circuitId: "bahrain", status: "Upcoming", sessions: [("FP1", "TBA", "upcoming"), ("FP2", "TBA", "upcoming"), ("FP3", "TBA", "upcoming"), ("Qualifying", "TBA", "upcoming"), ("Race", "TBA", "upcoming")])
    ]
    static let liveRows: [LiveRow] = []
    static let pitFeed: [PitFeedItem] = []
    static let raceControl: [RaceControlItem] = []
    static let news: [LocalNews] = []
}

private extension String {
    var normalizedCircuitKey: String {
        lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
    }
}
