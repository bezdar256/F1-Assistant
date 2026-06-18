import Foundation

final class AnalyticsViewModel {
    private let service = JolpicaService()
    private(set) var drivers = FallbackData.drivers.sorted { $0.position < $1.position }
    private(set) var teams = FallbackData.teams.sorted { $0.position < $1.position }
    var left = FallbackData.drivers[0]
    var right = FallbackData.drivers[1]

    func load() async {
        let driverResponse = try? await service.driverStandings()
        let constructorResponse = try? await service.constructorStandings()

        if let standings = driverResponse?.mrData.standingsTable?.standingsLists.first?.driverStandings, !standings.isEmpty {
            drivers = standings.enumerated().map { F1DataMapper.localDriver(from: $0.element, index: $0.offset) }
            left = drivers.indices.contains(0) ? drivers[0] : left
            right = drivers.indices.contains(1) ? drivers[1] : right
        }

        if let constructors = constructorResponse?.mrData.standingsTable?.standingsLists.first?.constructorStandings, !constructors.isEmpty {
            teams = constructors.enumerated().map { F1DataMapper.localTeam(from: $0.element, index: $0.offset, drivers: drivers) }
        }
    }

    func selectLeft(_ index: Int) {
        guard drivers.indices.contains(index) else { return }
        left = drivers[index]
    }

    func selectRight(_ index: Int) {
        guard drivers.indices.contains(index) else { return }
        right = drivers[index]
    }
}
