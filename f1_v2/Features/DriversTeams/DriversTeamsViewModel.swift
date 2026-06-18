import Foundation

final class DriversTeamsViewModel {
    private(set) var drivers = FallbackData.drivers.sorted { $0.position < $1.position }
    private(set) var sourceLabel = "Waiting for live data"
    private let service = JolpicaService()

    func load() async {
        guard let response = try? await service.driverStandings(),
              let standings = response.mrData.standingsTable?.standingsLists.first?.driverStandings,
              !standings.isEmpty else { return }

        sourceLabel = "\(SeasonConfig.currentSeason) driver standings"
        drivers = standings.enumerated().map { F1DataMapper.localDriver(from: $0.element, index: $0.offset) }
    }
}
