import Foundation

enum RecommendationEngine {
    static func makeRecommendation(weather: Weather, on date: Date = Date()) -> DailyRecommendation {
        let summary = generateSummary(weather: weather, on: date)

        return DailyRecommendation(
            summary: summary,
            focus: focusText(weather: weather, on: date),
            detail: detailText(weather: weather, on: date)
        )
    }

    static func generateSummary(weather: Weather, on date: Date = Date()) -> String {
        var ideas: [String] = []

        if weather.rainChance > 60 {
            ideas.append("indoor activities, cafes, malls, or museums")
        }

        if weather.temperature < 5 {
            ideas.append("warm food and comfortable indoor places")
        }

        if weather.condition.localizedCaseInsensitiveContains("sunny") {
            ideas.append("parks, walking routes, viewpoints, or outdoor dining")
        }

        ideas.append(isWeekend(date) ? "a longer outing" : "a short nearby stop")

        return "Today is a good day for \(ideas.joined(separator: ", "))."
    }

    private static func focusText(weather: Weather, on date: Date) -> String {
        if weather.rainChance > 60 {
            return isWeekend(date) ? "Cozy indoor day" : "Quick indoor plan"
        }

        if weather.temperature < 5 {
            return "Warm and comfortable"
        }

        if weather.condition.localizedCaseInsensitiveContains("sunny") {
            return isWeekend(date) ? "Outdoor exploring" : "Fresh-air break"
        }

        return isWeekend(date) ? "Flexible weekend" : "Simple nearby plan"
    }

    private static func detailText(weather: Weather, on date: Date) -> String {
        var details: [String] = []

        if weather.rainChance > 60 {
            details.append("Start with an indoor place such as a cafe, mall, or museum so your plans stay comfortable.")
        }

        if weather.temperature < 5 {
            details.append("Choose warm food and avoid long outdoor waits.")
        }

        if weather.condition.localizedCaseInsensitiveContains("sunny") {
            details.append("Use the good weather for a park walk, viewpoint, or outdoor meal.")
        }

        details.append(isWeekend(date) ? "Since it is the weekend, you can plan something a little longer." : "Since it is a weekday, keep it nearby and easy to fit into the day.")

        return details.joined(separator: " ")
    }

    private static func isWeekend(_ date: Date) -> Bool {
        Calendar.current.isDateInWeekend(date)
    }
}
