import Foundation

final class CalendarViewModel {
    private(set) var races = FallbackData.races
    private(set) var circuits = FallbackData.circuits
    private(set) var sourceLabel = "Waiting for live data"
    private let service = JolpicaService()

    func load() async {
        guard let response = try? await service.schedule(),
              let apiRaces = response.mrData.raceTable?.races,
              !apiRaces.isEmpty else { return }

        sourceLabel = "\(SeasonConfig.currentSeason) calendar"
        let nextIndex = apiRaces.firstIndex { $0.date >= DateFormatterHelper.apiToday }
        races = apiRaces.enumerated().map { F1DataMapper.localRace(from: $0.element, index: $0.offset, nextIndex: nextIndex) }
        circuits = apiRaces.map { F1DataMapper.localCircuit(from: $0) }
    }
}
