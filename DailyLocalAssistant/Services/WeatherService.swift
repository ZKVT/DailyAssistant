import CoreLocation
import Foundation
import WeatherKit

enum WeatherServiceError: Error {
    case unavailable
}

struct WeatherService {
    private let service = WeatherKit.WeatherService.shared

    func fetchWeather(for location: CLLocation) async throws -> Weather {
        do {
            let weather = try await service.weather(for: location)
            let current = weather.currentWeather
            let hourly = weather.hourlyForecast.forecast.first
            let temperature = Int(current.temperature.converted(to: .celsius).value.rounded())
            let feelsLike = Int(current.apparentTemperature.converted(to: .celsius).value.rounded())
            let rainChance = Int(((hourly?.precipitationChance ?? 0) * 100).rounded())
            let condition = formattedCondition(String(describing: current.condition))

            return Weather(
                temperature: temperature,
                condition: condition,
                rainChance: rainChance,
                suggestion: suggestion(for: temperature, condition: condition, rainChance: rainChance),
                symbolName: symbolName(for: condition, rainChance: rainChance),
                feelsLikeTemperature: feelsLike,
                humidity: Int((current.humidity * 100).rounded()),
                windSpeed: Int(current.wind.speed.converted(to: .kilometersPerHour).value.rounded()),
                updatedAt: current.date,
                isLive: true
            )
        } catch {
            throw WeatherServiceError.unavailable
        }
    }

    private func formattedCondition(_ rawValue: String) -> String {
        rawValue
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
    }

    private func suggestion(for temperature: Int, condition: String, rainChance: Int) -> String {
        if rainChance > 60 {
            return "Bring an umbrella and keep a comfortable indoor plan ready."
        }

        if temperature < 5 {
            return "Choose warm food and limit long outdoor stops."
        }

        if condition.localizedCaseInsensitiveContains("sun") || condition.localizedCaseInsensitiveContains("clear") {
            return "Great day for a walk, park visit, or outdoor dining."
        }

        return "Keep plans flexible and choose something nearby."
    }

    private func symbolName(for condition: String, rainChance: Int) -> String {
        if rainChance > 60 || condition.localizedCaseInsensitiveContains("rain") {
            return "cloud.rain.fill"
        }

        if condition.localizedCaseInsensitiveContains("snow") {
            return "snowflake"
        }

        if condition.localizedCaseInsensitiveContains("sun") || condition.localizedCaseInsensitiveContains("clear") {
            return "sun.max.fill"
        }

        if condition.localizedCaseInsensitiveContains("cloud") {
            return "cloud.fill"
        }

        return "cloud.sun.fill"
    }
}
