import Foundation

final class LiveRaceViewModel {
    private let openF1 = OpenF1Service()
    private let f1 = JolpicaService()

    private(set) var rows: [LiveRow] = []
    private(set) var raceControl: [RaceControlItem] = []
    private(set) var pitFeed: [PitFeedItem] = []
    private(set) var title = "Live"
    private(set) var lapText = "Checking current session"
    private(set) var weatherText = "Weather updates appear when the session feed is available"
    private(set) var statusValue = "SYNC"

    func load() async {
        rows = []
        raceControl = []
        pitFeed = []

        do {
            let sessions = try await openF1.sessions(year: SeasonConfig.currentSeason)
            guard let session = bestSession(from: sessions) else {
                try await loadNextRaceContext()
                return
            }

            async let driversTask = openF1.drivers(sessionKey: session.sessionKey)
            async let positionsTask = openF1.positions(sessionKey: session.sessionKey)
            async let intervalsTask = try? openF1.intervals(sessionKey: session.sessionKey)
            async let stintsTask = try? openF1.stints(sessionKey: session.sessionKey)
            async let pitsTask = try? openF1.pits(sessionKey: session.sessionKey)
            async let weatherTask = try? openF1.weather(sessionKey: session.sessionKey)
            async let controlTask = try? openF1.raceControl(sessionKey: session.sessionKey)

            let drivers = try await driversTask
            let positions = try await positionsTask
            let intervals = await intervalsTask ?? []
            let stints = await stintsTask ?? []
            let pits = await pitsTask ?? []
            let weather = await weatherTask ?? []
            let control = await controlTask ?? []

            guard !drivers.isEmpty, !positions.isEmpty else {
                try await loadNextRaceContext()
                return
            }

            let latestPositions = Dictionary(grouping: positions, by: { $0.driverNumber })
                .compactMapValues { $0.sorted { ($0.date ?? "") > ($1.date ?? "") }.first }
            let latestIntervals = Dictionary(grouping: intervals, by: { $0.driverNumber })
                .compactMapValues { $0.sorted { ($0.date ?? "") > ($1.date ?? "") }.first }
            let latestStints = Dictionary(grouping: stints, by: { $0.driverNumber })
                .compactMapValues { $0.sorted { ($0.stintNumber ?? 0) > ($1.stintNumber ?? 0) }.first }
            let pitCounts = Dictionary(grouping: pits, by: { $0.driverNumber }).mapValues { $0.count }

            var builtRows: [LiveRow] = []
            for driver in drivers {
                guard let position = latestPositions[driver.driverNumber] else { continue }
                let interval = latestIntervals[driver.driverNumber]
                let gap: String = position.position == 1 ? "Leader" : readableGap(interval?.gapToLeader, fallback: interval?.interval)
                let seconds = numericGap(from: gap) ?? Double(position.position * 2)
                builtRows.append(
                    LiveRow(
                        position: position.position,
                        driver: driver.fullName ?? driver.broadcastName ?? "Driver #\(driver.driverNumber)",
                        code: driver.nameAcronym ?? String((driver.lastName ?? "F1").prefix(3)).uppercased(),
                        team: driver.teamName ?? "F1 Team",
                        gap: gap,
                        tyre: latestStints[driver.driverNumber]?.compound ?? "—",
                        pitStops: pitCounts[driver.driverNumber] ?? 0,
                        interval: seconds
                    )
                )
            }
            rows = builtRows.sorted { $0.position < $1.position }

            if let currentWeather = weather.sorted(by: { ($0.date ?? "") > ($1.date ?? "") }).first {
                let rain = (currentWeather.rainfall ?? 0) > 0 ? "Rain" : "Dry"
                weatherText = "Air \(Int(currentWeather.airTemperature ?? 0))°C • Track \(Int(currentWeather.trackTemperature ?? 0))°C • \(rain)"
            }

            raceControl = control.suffix(8).enumerated().map { index, item in
                RaceControlItem(lap: item.lapNumber ?? index + 1, title: item.category ?? item.flag ?? "Race Control", message: item.message ?? "Session update", color: F1Colors.warning)
            }
            pitFeed = pits.suffix(8).map {
                PitFeedItem(lap: $0.lapNumber ?? 0, driver: "#\($0.driverNumber)", duration: $0.pitDuration.map { String(format: "%.2fs", $0) } ?? "—", change: "Pit lane")
            }

            title = active(session) ? "Live Timing" : "Latest Timing"
            lapText = [session.location, session.sessionName].compactMap { $0 }.joined(separator: " • ")
            statusValue = active(session) ? "LIVE" : "LATEST"
        } catch {
            try? await loadNextRaceContext()
        }
    }

    private func loadNextRaceContext() async throws {
        let next = try await f1.nextRace()
        guard let race = next.mrData.raceTable?.races.first else { throw NetworkError.invalidResponse }
        let local = F1DataMapper.localRace(from: race, index: 0, nextIndex: 0)
        title = "Next Session"
        lapText = "\(local.title) • \(DateFormatterHelper.pretty(local.date))"
        weatherText = "Track conditions will update when the session feed is available."
        statusValue = "SOON"
        rows = []
        raceControl = local.sessions.map { RaceControlItem(lap: 0, title: $0.0, message: "\($0.1) • \($0.2.capitalized)", color: F1Colors.primaryRed) }
        pitFeed = []
    }

    private func bestSession(from sessions: [OpenF1Session]) -> OpenF1Session? {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        if let live = sessions.first(where: { session in
            guard let startText = session.dateStart, let endText = session.dateEnd,
                  let start = formatter.date(from: startText), let end = formatter.date(from: endText) else { return false }
            return start <= now && now <= end
        }) { return live }

        return sessions
            .filter { ($0.sessionName ?? "").localizedCaseInsensitiveContains("race") || ($0.sessionName ?? "").localizedCaseInsensitiveContains("qualifying") }
            .sorted { ($0.dateStart ?? "") > ($1.dateStart ?? "") }
            .first ?? sessions.sorted { ($0.dateStart ?? "") > ($1.dateStart ?? "") }.first
    }

    private func active(_ session: OpenF1Session) -> Bool {
        let formatter = ISO8601DateFormatter()
        guard let startText = session.dateStart, let endText = session.dateEnd,
              let start = formatter.date(from: startText), let end = formatter.date(from: endText) else { return false }
        let now = Date()
        return start <= now && now <= end
    }

    private func readableGap(_ primary: DoubleOrString?, fallback: DoubleOrString?) -> String {
        if let primary, primary.description != "—" { return primary.description }
        if let fallback, fallback.description != "—" { return fallback.description }
        return "—"
    }

    private func numericGap(from text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "s", with: "")
            .replacingOccurrences(of: "Leader", with: "0")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned)
    }
}
