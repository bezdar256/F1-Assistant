import Foundation

enum F1DataMapper {
    static func sessions(for race: Race, status: String) -> [(String, String, String)] {
        let isCompleted = status == "Completed"
        var result: [(String, String, String)] = []
        result.append(("FP1", sessionText(race.firstPractice), isCompleted ? "completed" : "upcoming"))
        result.append(("FP2", sessionText(race.secondPractice), isCompleted ? "completed" : "upcoming"))
        if let sprint = race.sprint {
            result.append(("Sprint", sessionText(sprint), isCompleted ? "completed" : "upcoming"))
        } else {
            result.append(("FP3", sessionText(race.thirdPractice), isCompleted ? "completed" : "upcoming"))
        }
        result.append(("Qualifying", sessionText(race.qualifying), isCompleted ? "completed" : "upcoming"))
        result.append(("Race", race.date, isCompleted ? "completed" : "upcoming"))
        return result
    }

    static func localRace(from race: Race, index: Int, nextIndex: Int?) -> LocalRace {
        let status: String
        if race.date < DateFormatterHelper.apiToday {
            status = "Completed"
        } else if nextIndex == index {
            status = "Next Race"
        } else {
            status = "Upcoming"
        }

        return LocalRace(
            round: Int(race.round) ?? index + 1,
            title: race.raceName,
            date: race.date,
            circuitId: race.circuit.circuitId,
            status: status,
            sessions: sessions(for: race, status: status)
        )
    }

    static func localCircuit(from race: Race) -> LocalCircuit {
        let known = FallbackData.circuit(for: race.circuit.circuitId)
        if known.length != "TBA" {
            return known
        }

        let id = race.circuit.circuitId
        return LocalCircuit(
            id: id,
            name: race.circuit.circuitName,
            country: race.circuit.location.country,
            city: race.circuit.location.locality,
            photoName: "f1_hero",
            trackImageName: "map_placeholder",
            length: "TBA",
            turns: 0,
            laps: 0,
            distance: "TBA",
            lapRecord: "TBA",
            drs: "TBA",
            previousWinner: "TBA"
        )
    }

    static func localDriver(from standing: DriverStanding, index: Int) -> LocalDriver {
        let driver = standing.driver
        let constructor = standing.constructors.first
        let local = FallbackData.drivers.first {
            $0.id == driver.driverId ||
            $0.code == driver.code ||
            $0.name.localizedCaseInsensitiveContains(driver.familyName)
        }

        return LocalDriver(
            id: driver.driverId,
            name: driver.fullName,
            code: driver.code ?? String(driver.familyName.prefix(3)).uppercased(),
            number: driver.permanentNumber ?? local?.number ?? "—",
            teamId: constructor?.constructorId ?? local?.teamId ?? "team",
            team: constructor?.name ?? local?.team ?? "F1 Team",
            nationality: driver.nationality,
            imageName: local?.imageName ?? ImageMapper.driver(driver.driverId),
            position: Int(standing.position) ?? index + 1,
            points: Double(standing.points) ?? 0,
            wins: Int(standing.wins) ?? 0,
            podiums: 0,
            averageFinish: 0,
            lastResults: []
        )
    }

    static func localTeam(from standing: ConstructorStanding, index: Int, drivers: [LocalDriver]) -> LocalTeam {
        let constructor = standing.constructor
        let local = FallbackData.teams.first {
            $0.id == constructor.constructorId ||
            $0.name.localizedCaseInsensitiveCompare(constructor.name) == .orderedSame ||
            constructor.name.localizedCaseInsensitiveContains($0.name)
        }
        let teamDrivers = drivers
            .filter { $0.teamId == constructor.constructorId || $0.team == constructor.name }
            .map { $0.name }

        return LocalTeam(
            id: constructor.constructorId,
            name: constructor.name,
            drivers: teamDrivers.isEmpty ? (local?.drivers ?? []) : teamDrivers,
            logoName: local?.logoName ?? ImageMapper.teamLogo(constructor.constructorId),
            carImageName: local?.carImageName ?? ImageMapper.teamCar(constructor.constructorId),
            colorHex: local?.colorHex ?? "#E10600",
            position: Int(standing.position) ?? index + 1,
            points: Double(standing.points) ?? 0,
            wins: Int(standing.wins) ?? 0,
            podiums: 0,
            trend: []
        )
    }

    private static func sessionText(_ session: SessionTime?) -> String {
        guard let session else { return "TBA" }
        if let time = session.time, !time.isEmpty { return "\(session.date) • \(String(time.prefix(5))) UTC" }
        return session.date
    }
}
