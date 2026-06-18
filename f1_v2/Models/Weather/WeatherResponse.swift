import Foundation

struct WeatherResponse: Codable {
    let weather: [WeatherItem]
    let main: WeatherMain
    let wind: WeatherWind?
    let name: String?
}
struct WeatherItem: Codable { let description: String; let icon: String? }
struct WeatherMain: Codable { let temp: Double; let feelsLike: Double?; let humidity: Int? }
struct WeatherWind: Codable { let speed: Double? }
