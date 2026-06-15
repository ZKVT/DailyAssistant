import Foundation

struct Weather: Identifiable, Hashable {
    let id = UUID()
    let temperature: Int
    let condition: String
    let rainChance: Int
    let suggestion: String
    let symbolName: String
    let feelsLikeTemperature: Int?
    let humidity: Int?
    let windSpeed: Int?
    let updatedAt: Date?
    let isLive: Bool

    init(
        temperature: Int,
        condition: String,
        rainChance: Int,
        suggestion: String,
        symbolName: String,
        feelsLikeTemperature: Int? = nil,
        humidity: Int? = nil,
        windSpeed: Int? = nil,
        updatedAt: Date? = nil,
        isLive: Bool = false
    ) {
        self.temperature = temperature
        self.condition = condition
        self.rainChance = rainChance
        self.suggestion = suggestion
        self.symbolName = symbolName
        self.feelsLikeTemperature = feelsLikeTemperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.updatedAt = updatedAt
        self.isLive = isLive
    }
}
