import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var viewState: ViewState = .loading
    @Published var location: String
    @Published var weather: Weather
    @Published var recommendation: DailyRecommendation
    @Published var foodSuggestions: [FoodSuggestion]
    @Published var newsItems: [NewsItem]
    @Published var activities: [ActivitySuggestion]

    let currentDate: Date
    private var refreshCount = 0

    init(
        location: String = MockDailyData.location,
        weather: Weather = MockDailyData.weather,
        recommendation: DailyRecommendation? = nil,
        foodSuggestions: [FoodSuggestion] = MockDailyData.foodSuggestions,
        newsItems: [NewsItem] = MockDailyData.newsItems,
        activities: [ActivitySuggestion] = MockDailyData.activities,
        currentDate: Date = Date()
    ) {
        self.location = location
        self.weather = weather
        self.recommendation = recommendation ?? RecommendationEngine.makeRecommendation(weather: weather, on: currentDate)
        self.foodSuggestions = foodSuggestions
        self.newsItems = newsItems
        self.activities = activities
        self.currentDate = currentDate
    }

    func loadIfNeeded() async {
        guard viewState == .loading else { return }

        try? await Task.sleep(nanoseconds: 500_000_000)
        updateViewState()
    }

    func refresh() async {
        try? await Task.sleep(nanoseconds: 700_000_000)

        refreshCount += 1
        recommendation = RecommendationEngine.makeRecommendation(weather: weather, on: Date())

        if refreshCount.isMultiple(of: 2) {
            recommendation = DailyRecommendation(
                summary: "\(recommendation.summary) Freshly updated with an easy nearby option.",
                focus: recommendation.focus,
                detail: "\(recommendation.detail) This refresh also prioritizes places close to your current area."
            )
        }

        updateViewState()
    }

    private func updateViewState() {
        if foodSuggestions.isEmpty && newsItems.isEmpty && activities.isEmpty {
            viewState = .empty
        } else {
            viewState = .loaded
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: currentDate)

        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    var formattedDate: String {
        currentDate.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    func weatherDetailPage() -> DetailPage {
        DetailPage(
            id: "weather-today",
            kind: .weather,
            title: "Today's Weather",
            subtitle: "\(weather.temperature)°C - \(weather.condition)",
            symbolName: weather.symbolName,
            accentName: "WeatherAccent",
            body: weather.suggestion,
            highlights: [
                "Rain chance: \(weather.rainChance)%",
                "Condition: \(weather.condition)",
                "Plan: Keep an umbrella nearby"
            ],
            metadata: [
                DetailMetadata(label: "Temperature", value: "\(weather.temperature)°C"),
                DetailMetadata(label: "Condition", value: weather.condition),
                DetailMetadata(label: "Rain chance", value: "\(weather.rainChance)%")
            ],
            actionTitle: "Save for Later",
            favoriteID: nil
        )
    }

    func recommendationDetailPage() -> DetailPage {
        DetailPage(
            id: "recommendation-today",
            kind: .recommendation,
            title: "Today's Recommendation",
            subtitle: recommendation.focus,
            symbolName: "sparkles",
            accentName: "RecommendationAccent",
            body: recommendation.detail,
            highlights: [
                "Best mood: \(recommendation.focus)",
                "Food: warm and convenient",
                "Activity: flexible indoor plans"
            ],
            metadata: [
                DetailMetadata(label: "Focus", value: recommendation.focus),
                DetailMetadata(label: "Location", value: location),
                DetailMetadata(label: "Weather fit", value: weather.condition)
            ],
            actionTitle: "Save for Later",
            favoriteID: nil
        )
    }

    func foodDetailPage(for item: FoodSuggestion) -> DetailPage {
        DetailPage(
            id: item.id,
            kind: .food,
            title: item.name,
            subtitle: item.category,
            symbolName: "fork.knife.circle.fill",
            accentName: "FoodAccent",
            body: item.note,
            highlights: [
                "Distance: \(item.distance)",
                "Rating: \(item.rating)",
                "Good for: a simple local meal"
            ],
            metadata: [
                DetailMetadata(label: "Category", value: item.category),
                DetailMetadata(label: "Distance", value: item.distance),
                DetailMetadata(label: "Rating", value: item.rating),
                DetailMetadata(label: "Weather fit", value: weather.rainChance > 60 ? "Good indoor option" : "Easy nearby meal")
            ],
            actionTitle: "Get Directions",
            favoriteID: item.id
        )
    }

    func newsDetailPage(for item: NewsItem) -> DetailPage {
        DetailPage(
            id: item.id,
            kind: .news,
            title: item.title,
            subtitle: "\(item.source) - \(item.time)",
            symbolName: "newspaper.fill",
            accentName: "NewsAccent",
            body: item.summary,
            highlights: [
                "Source: \(item.source)",
                "Updated: \(item.time)",
                "Type: local headline"
            ],
            metadata: [
                DetailMetadata(label: "Source", value: item.source),
                DetailMetadata(label: "Time", value: item.time),
                DetailMetadata(label: "Category", value: "Local news")
            ],
            actionTitle: "Read Full Article",
            favoriteID: item.id
        )
    }

    func activityDetailPage(for item: ActivitySuggestion) -> DetailPage {
        DetailPage(
            id: item.id,
            kind: .activity,
            title: item.title,
            subtitle: item.locationHint,
            symbolName: item.symbolName,
            accentName: "ActivityAccent",
            body: item.note,
            highlights: [
                "Where: \(item.locationHint)",
                "Time needed: \(item.duration)",
                "Effort: easy"
            ],
            metadata: [
                DetailMetadata(label: "Location", value: item.locationHint),
                DetailMetadata(label: "Duration", value: item.duration),
                DetailMetadata(label: "Weather fit", value: weather.rainChance > 60 ? "Check conditions first" : "Good for today")
            ],
            actionTitle: "Get Directions",
            favoriteID: item.id
        )
    }
}
