import Foundation

final class JolpicaService {
    private let season = SeasonConfig.currentSeason
    private let cache = CacheStorage.shared

    func schedule() async throws -> RaceScheduleResponse {
        try await request(primary: "\(season).json", fallback: "current.json", cacheKey: "jolpica_schedule_\(season)")
    }

    func nextRace() async throws -> RaceScheduleResponse {
        try await request(primary: "\(season)/next.json", fallback: "current/next.json", cacheKey: "jolpica_next_\(season)")
    }

    func driverStandings() async throws -> DriverStandingsResponse {
        try await request(primary: "\(season)/driverStandings.json", fallback: "current/driverStandings.json", cacheKey: "jolpica_drivers_\(season)")
    }

    func constructorStandings() async throws -> ConstructorStandingsResponse {
        try await request(primary: "\(season)/constructorStandings.json", fallback: "current/constructorStandings.json", cacheKey: "jolpica_constructors_\(season)")
    }

    func lastRaceResults() async throws -> RaceResultsResponse {
        try await request(primary: "\(season)/last/results.json", fallback: "current/last/results.json", cacheKey: "jolpica_last_results_\(season)")
    }

    func raceResults(round: String) async throws -> RaceResultsResponse {
        try await request(primary: "\(season)/\(round)/results.json", fallback: "current/\(round)/results.json", cacheKey: "jolpica_results_\(season)_\(round)")
    }

    func raceResults(season: Int, circuitId: String) async throws -> RaceResultsResponse {
        try await request(primary: "\(season)/circuits/\(circuitId)/results/1.json", fallback: "\(season)/circuits/\(circuitId)/results.json", cacheKey: "jolpica_winner_\(season)_\(circuitId)")
    }

    func qualifying(round: String) async throws -> QualifyingResponse {
        try await request(primary: "\(season)/\(round)/qualifying.json", fallback: "current/\(round)/qualifying.json", cacheKey: "jolpica_qualifying_\(season)_\(round)")
    }

    func winners(circuitId: String, seasons: [Int] = SeasonConfig.previousSeasons) async -> [(Int, String)] {
        var rows: [(Int, String)] = []
        for year in seasons {
            guard let result = try? await raceResults(season: year, circuitId: circuitId),
                  let winner = result.mrData.raceTable.races.first?.results?.first?.driver.fullName else { continue }
            rows.append((year, winner))
        }
        return rows
    }

    private func request<T: Codable>(primary: String, fallback: String, cacheKey: String) async throws -> T {
        if let value: T = try? await APIClient.shared.request(APIEndpoint.jolpica(primary)) {
            cache.save(value, for: cacheKey)
            return value
        }
        if let value: T = try? await APIClient.shared.request(APIEndpoint.jolpica(fallback)) {
            cache.save(value, for: cacheKey)
            return value
        }
        if let cached = cache.load(T.self, for: cacheKey) { return cached }
        throw NetworkError.invalidResponse
    }
}

final class OpenF1Service {
    func sessions(year: Int = SeasonConfig.currentSeason) async throws -> [OpenF1Session] {
        try await APIClient.shared.request(APIEndpoint.openF1("sessions", query: [URLQueryItem(name: "year", value: "\(year)")]))
    }
    func drivers(sessionKey: Int) async throws -> [OpenF1Driver] {
        try await APIClient.shared.request(APIEndpoint.openF1("drivers", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
    func positions(sessionKey: Int) async throws -> [OpenF1Position] {
        try await APIClient.shared.request(APIEndpoint.openF1("position", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
    func intervals(sessionKey: Int) async throws -> [OpenF1Interval] {
        try await APIClient.shared.request(APIEndpoint.openF1("intervals", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
    func pits(sessionKey: Int) async throws -> [OpenF1PitStop] {
        try await APIClient.shared.request(APIEndpoint.openF1("pit", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
    func stints(sessionKey: Int) async throws -> [OpenF1Stint] {
        try await APIClient.shared.request(APIEndpoint.openF1("stints", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
    func weather(sessionKey: Int) async throws -> [OpenF1Weather] {
        try await APIClient.shared.request(APIEndpoint.openF1("weather", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
    func raceControl(sessionKey: Int) async throws -> [OpenF1RaceControl] {
        try await APIClient.shared.request(APIEndpoint.openF1("race_control", query: [URLQueryItem(name: "session_key", value: "\(sessionKey)")]))
    }
}

final class WeatherService {
    func current(lat: Double, lon: Double) async throws -> WeatherResponse {
        try await APIClient.shared.request(APIEndpoint.weather(lat: lat, lon: lon))
    }
}

final class NewsService {
    private let feeds = [
        "https://www.motorsport.com/rss/f1/news/",
        "https://www.autosport.com/rss/f1/news/",
        "https://racingnews365.com/feed/news"
    ].compactMap(URL.init(string:))

    func news() async throws -> [LocalNews] {
        for feed in feeds {
            if let items = try? await load(feed), !items.isEmpty {
                CacheStorage.shared.save(items, for: "rss_news_cache")
                return items
            }
        }
        if let cached = CacheStorage.shared.load([LocalNews].self, for: "rss_news_cache"), !cached.isEmpty {
            return cached
        }
        return FallbackData.news
    }

    private func load(_ url: URL) async throws -> [LocalNews] {
        let data = try await APIClient.shared.data(url, timeout: 12)
        let parser = RSSParser(data: data, source: readableSource(from: url))
        return parser.parse().filter { !$0.title.isEmpty && !$0.url.isEmpty }
    }

    private func readableSource(from url: URL) -> String {
        let host = url.host ?? "F1 News"
        if host.contains("motorsport") { return "Motorsport" }
        if host.contains("autosport") { return "Autosport" }
        if host.contains("racingnews365") { return "RacingNews365" }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}

private final class RSSParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private let source: String
    private var items: [LocalNews] = []
    private var currentElement = ""
    private var insideItem = false
    private var title = ""
    private var link = ""
    private var summary = ""
    private var date = ""
    private var image = "news_f1"

    init(data: Data, source: String) {
        self.parser = XMLParser(data: data)
        self.source = source
        super.init()
        self.parser.delegate = self
    }

    func parse() -> [LocalNews] {
        parser.parse()
        return Array(items.prefix(20))
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()
        if currentElement == "item" || currentElement == "entry" {
            insideItem = true
            title = ""; link = ""; summary = ""; date = ""; image = "news_f1"
        }
        if insideItem, currentElement == "enclosure", let url = attributeDict["url"], !url.isEmpty { image = url }
        if insideItem, currentElement == "media:content", let url = attributeDict["url"], !url.isEmpty { image = url }
        if insideItem, currentElement == "link", let href = attributeDict["href"], link.isEmpty { link = href }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        let value = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        switch currentElement {
        case "title": title += title.isEmpty ? value : " \(value)"
        case "link": link += link.isEmpty ? value : value
        case "description", "summary", "content:encoded": summary += summary.isEmpty ? value : " \(value)"
        case "pubdate", "published", "updated": date += date.isEmpty ? value : " \(value)"
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let end = elementName.lowercased()
        if end == "item" || end == "entry" {
            let cleanSummary = summary
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            items.append(LocalNews(title: title, source: source, date: formatted(date), summary: cleanSummary, imageName: image, url: link))
            insideItem = false
        }
    }

    private func formatted(_ raw: String) -> String {
        if raw.isEmpty { return "Latest" }
        return String(raw.prefix(16))
    }
}
