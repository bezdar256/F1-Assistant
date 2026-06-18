import UIKit

enum TeamColors {
    static func color(for idOrName: String) -> UIColor {
        let key = idOrName.normalizedKey
        if key.contains("mclaren") { return UIColor(hex: "#FF8700") }
        if key.contains("redbull") || key.contains("red_bull") { return UIColor(hex: "#1E41FF") }
        if key.contains("ferrari") { return UIColor(hex: "#DC0000") }
        if key.contains("mercedes") { return UIColor(hex: "#00D2BE") }
        if key.contains("aston") { return UIColor(hex: "#006F62") }
        if key.contains("williams") { return UIColor(hex: "#00A3E0") }
        if key.contains("alpine") { return UIColor(hex: "#0090FF") }
        if key.contains("haas") { return UIColor(hex: "#B6BABD") }
        if key.contains("racingbull") || key == "rb" || key.contains("visacashapp") { return UIColor(hex: "#6692FF") }
        if key.contains("sauber") || key.contains("audi") || key.contains("kick") { return UIColor(hex: "#00E701") }
        if key.contains("cadillac") { return UIColor(hex: "#B9975B") }
        return F1Colors.primaryRed
    }
}

enum ImageMapper {
    static func driver(_ idOrName: String) -> String {
        let key = idOrName.normalizedKey
        if key.contains("maxverstappen") || key == "verstappen" { return "verstappen" }
        if key.contains("landonorris") || key == "norris" { return "norris" }
        if key.contains("oscarpiastri") || key == "piastri" { return "piastri" }
        if key.contains("charlesleclerc") || key == "leclerc" || key == "lecler" { return "leclerc" }
        if key.contains("lewishamilton") || key == "hamilton" { return "hamilton" }
        if key.contains("georgerussell") || key == "russell" { return "russell" }
        if key.contains("fernandoalonso") || key == "alonso" { return "alonso" }
        if key.contains("carlossainz") || key == "sainz" { return "sainz" }
        if key.contains("alexalbon") || key == "albon" { return "albon" }
        if key.contains("kimiantonelli") || key.contains("antonelli") { return "antonelli" }
        if key.contains("olliebearman") || key.contains("bearman") { return "bearman" }
        if key.contains("gabrielbortoleto") || key.contains("bortoleto") { return "bortoleto" }
        if key.contains("valtteribottas") || key.contains("bottas") { return "bottas" }
        if key.contains("francocolapinto") || key.contains("colapinto") { return "colapinto" }
        if key.contains("pierregasly") || key.contains("gasly") { return "gasly" }
        if key.contains("isackhadjar") || key.contains("hadjar") { return "hadjar" }
        if key.contains("nicohulkenberg") || key.contains("hulkenberg") { return "hulkenberg" }
        if key.contains("liamlawson") || key.contains("lawson") { return "lawson" }
        if key.contains("arlindlindblad") || key.contains("lindblad") { return "lindblad" }
        if key.contains("estebanocon") || key.contains("ocon") { return "ocon" }
        if key.contains("sergioperez") || key.contains("perez") { return "perez" }
        if key.contains("lancestroll") || key.contains("stroll") { return "stroll" }
        return key
    }

    static func teamLogo(_ idOrName: String) -> String {
        "\(teamAssetKey(idOrName))_logo"
    }

    static func teamCar(_ idOrName: String) -> String {
        "\(teamAssetKey(idOrName))_car"
    }

    static func teamAssetKey(_ idOrName: String) -> String {
        let key = idOrName.normalizedKey
        if key.contains("mclaren") { return "mclaren" }
        if key.contains("redbull") || key.contains("red_bull") { return "redbull" }
        if key.contains("ferrari") { return "ferrari" }
        if key.contains("mercedes") { return "mercedes" }
        if key.contains("aston") { return "aston" }
        if key.contains("williams") { return "williams" }
        if key.contains("alpine") { return "alpine" }
        if key.contains("haas") { return "haas" }
        if key.contains("racingbull") || key == "rb" || key.contains("visacashapp") { return "racingbulls" }
        if key.contains("sauber") || key.contains("audi") || key.contains("kick") { return "audi" }
        if key.contains("cadillac") { return "cadillac" }
        return key
    }
}

private extension String {
    var normalizedKey: String {
        self.lowercased()
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ".", with: "")
    }
}
