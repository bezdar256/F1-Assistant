import Foundation

final class HomeViewModel {
    private let f1 = JolpicaService()
    private let newsService = NewsService()

    private(set) var nextRace = FallbackData.races.first { $0.status == "Next Race" } ?? FallbackData.races[0]
    private(set) var seasonRaces = FallbackData.races
    private(set) var circuits = FallbackData.circuits
    private(set) var topDrivers = Array(FallbackData.drivers.prefix(5))
    private(set) var topTeams = Array(FallbackData.teams.prefix(5))
    private(set) var news = Array(FallbackData.news.prefix(3))
    private(set) var sourceLabel = "Waiting for live data"

    var circuit: LocalCircuit {
        circuits.first { $0.id == nextRace.circuitId } ?? FallbackData.circuit(for: nextRace.circuitId)
    }

    var favoriteDriver: LocalDriver? {
        FavoritesStorage.shared.favoriteDriverId.flatMap { id in
            topDrivers.first { $0.id == id } ?? FallbackData.drivers.first { $0.id == id }
        }
    }

    var favoriteTeam: LocalTeam? {
        FavoritesStorage.shared.favoriteTeamId.flatMap { id in
            topTeams.first { $0.id == id } ?? FallbackData.teams.first { $0.id == id }
        }
    }

    func load() async {
        async let scheduleTask = try? f1.schedule()
        async let nextTask = try? f1.nextRace()
        async let driversTask = try? f1.driverStandings()
        async let constructorsTask = try? f1.constructorStandings()
        async let newsTask = try? newsService.news()

        let scheduleResponse = await scheduleTask
        let nextResponse = await nextTask
        let driverResponse = await driversTask
        let constructorResponse = await constructorsTask
        let newsResponse = await newsTask

        if let races = scheduleResponse?.mrData.raceTable?.races, !races.isEmpty {
            sourceLabel = "Live \(SeasonConfig.currentSeason) data"
            let nextIndex = races.firstIndex { $0.date >= DateFormatterHelper.apiToday }
            seasonRaces = races.enumerated().map { F1DataMapper.localRace(from: $0.element, index: $0.offset, nextIndex: nextIndex) }
            circuits = races.map { F1DataMapper.localCircuit(from: $0) }
        }

        if let apiNext = nextResponse?.mrData.raceTable?.races.first {
            nextRace = F1DataMapper.localRace(from: apiNext, index: 0, nextIndex: 0)
        } else if let upcoming = seasonRaces.first(where: { $0.status == "Next Race" || $0.status == "Upcoming" }) {
            nextRace = upcoming
        }

        if let standings = driverResponse?.mrData.standingsTable?.standingsLists.first?.driverStandings, !standings.isEmpty {
            topDrivers = standings.prefix(20).enumerated().map { F1DataMapper.localDriver(from: $0.element, index: $0.offset) }
        }

        if let standings = constructorResponse?.mrData.standingsTable?.standingsLists.first?.constructorStandings, !standings.isEmpty {
            topTeams = standings.prefix(10).enumerated().map { F1DataMapper.localTeam(from: $0.element, index: $0.offset, drivers: topDrivers) }
        }

        if let articles = newsResponse, !articles.isEmpty {
            news = Array(articles.prefix(3))
        }
    }
}
