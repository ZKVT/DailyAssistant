import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var viewState: ViewState = .loading
    @Published var location: String
    @Published var weather: Weather
    @Published var weatherSourceLabel: String
    @Published var recommendation: DailyRecommendation
    @Published var foodSuggestions: [FoodSuggestion]
    @Published var foodSourceLabel: String
    @Published var newsItems: [NewsItem]
    @Published var newsSourceLabel: String
    @Published var activities: [ActivitySuggestion]
    @Published var activitySourceLabel: String

    let currentDate: Date
    private let weatherService: WeatherService
    private let mapSearchService: MapSearchService
    private let newsService: NewsService
    private var refreshCount = 0

    init(
        location: String = MockDailyData.location,
        weather: Weather = MockDailyData.weather,
        recommendation: DailyRecommendation? = nil,
        foodSuggestions: [FoodSuggestion] = MockDailyData.foodSuggestions,
        newsItems: [NewsItem] = MockDailyData.newsItems,
        activities: [ActivitySuggestion] = MockDailyData.activities,
        currentDate: Date = Date(),
        weatherService: WeatherService = WeatherService(),
        mapSearchService: MapSearchService = MapSearchService(),
        newsService: NewsService = NewsService()
    ) {
        self.location = location
        self.weather = weather
        self.weatherSourceLabel = weather.isLive ? "Live Weather" : "Sample Weather"
        self.recommendation = recommendation ?? RecommendationEngine.makeRecommendation(weather: weather, on: currentDate)
        self.foodSuggestions = foodSuggestions
        self.foodSourceLabel = foodSuggestions.contains { $0.isFromLiveSearch } ? "Live Nearby" : "Sample Suggestions"
        self.newsItems = newsItems
        self.newsSourceLabel = newsItems.contains { $0.isFromLiveSource } ? "Live News" : "Sample News"
        self.activities = activities
        self.activitySourceLabel = activities.contains { $0.isFromLiveSearch } ? "Live Nearby" : "Sample Suggestions"
        self.currentDate = currentDate
        self.weatherService = weatherService
        self.mapSearchService = mapSearchService
        self.newsService = newsService
    }

    func loadIfNeeded(locationManager: LocationManager? = nil) async {
        guard viewState == .loading else { return }

        try? await Task.sleep(nanoseconds: 500_000_000)
        await refreshWeatherIfPossible(locationManager: locationManager)
        await refreshMapSuggestionsIfPossible(locationManager: locationManager)
        await refreshNews()
        recommendation = RecommendationEngine.makeRecommendation(weather: weather, on: Date())
        updateViewState()
    }

    func refresh(locationManager: LocationManager? = nil) async {
        try? await Task.sleep(nanoseconds: 700_000_000)

        refreshCount += 1
        await refreshWeatherIfPossible(locationManager: locationManager)
        await refreshMapSuggestionsIfPossible(locationManager: locationManager)
        await refreshNews()
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

    private func refreshWeatherIfPossible(locationManager: LocationManager?) async {
        guard
            let locationManager,
            locationManager.isAuthorized,
            let latestLocation = locationManager.latestLocation
        else {
            useSampleWeather(locationName: MockDailyData.location)
            return
        }

        do {
            weather = try await weatherService.fetchWeather(for: latestLocation)
            location = locationManager.locationName
            weatherSourceLabel = "Live Weather"
        } catch {
            useSampleWeather(locationName: locationManager.locationName)
        }
    }

    private func useSampleWeather(locationName: String) {
        weather = MockDailyData.weather
        location = locationName.isEmpty ? MockDailyData.location : locationName
        weatherSourceLabel = "Sample Weather"
    }

    private func refreshMapSuggestionsIfPossible(locationManager: LocationManager?) async {
        guard
            let locationManager,
            locationManager.isAuthorized,
            let latestLocation = locationManager.latestLocation
        else {
            useSampleMapSuggestions()
            return
        }

        async let food = mapSearchService.fetchNearbyFood(from: latestLocation)
        async let activities = mapSearchService.fetchNearbyActivities(from: latestLocation, weather: weather)

        let fetchedFood = await food
        let fetchedActivities = await activities

        foodSuggestions = fetchedFood
        self.activities = fetchedActivities
        foodSourceLabel = fetchedFood.contains { $0.isFromLiveSearch } ? "Live Nearby" : "Sample Suggestions"
        activitySourceLabel = fetchedActivities.contains { $0.isFromLiveSearch } ? "Live Nearby" : "Sample Suggestions"
    }

    private func useSampleMapSuggestions() {
        foodSuggestions = MockDailyData.foodSuggestions
        activities = MockDailyData.activities
        foodSourceLabel = "Sample Suggestions"
        activitySourceLabel = "Sample Suggestions"
    }

    private func refreshNews() async {
        let fetchedNews = await newsService.fetchLocalNews(near: location)
        newsItems = fetchedNews
        newsSourceLabel = fetchedNews.contains { $0.isFromLiveSource } ? "Live News" : "Sample News"
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
            favoriteID: nil,
            mapLaunchInfo: nil,
            articleURL: nil
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
            favoriteID: nil,
            mapLaunchInfo: nil,
            articleURL: nil
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
                DetailMetadata(label: "Weather fit", value: weather.rainChance > 60 ? "Good indoor option" : "Easy nearby meal"),
                DetailMetadata(label: "Source", value: item.isFromLiveSearch ? "Apple Maps" : "Sample Data")
            ] + optionalMetadata([
                ("Address", item.address),
                ("Phone", item.phoneNumber)
            ]),
            actionTitle: "Open in Maps",
            favoriteID: item.id,
            mapLaunchInfo: makeMapLaunchInfo(latitude: item.latitude, longitude: item.longitude, name: item.mapItemName ?? item.name),
            articleURL: nil
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
                DetailMetadata(label: "Source", value: item.sourceName),
                DetailMetadata(label: "Time", value: item.time),
                DetailMetadata(label: "Category", value: "Local news"),
                DetailMetadata(label: "Status", value: item.isFromLiveSource ? "Live RSS" : "Sample Data")
            ] + optionalMetadata([
                ("Article", item.url?.absoluteString)
            ]),
            actionTitle: "Read Full Article",
            favoriteID: item.id,
            mapLaunchInfo: nil,
            articleURL: item.url
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
                DetailMetadata(label: "Category", value: item.category ?? item.locationHint),
                DetailMetadata(label: "Location", value: item.locationHint),
                DetailMetadata(label: "Duration", value: item.duration),
                DetailMetadata(label: "Weather fit", value: weather.rainChance > 60 ? "Check conditions first" : "Good for today"),
                DetailMetadata(label: "Source", value: item.isFromLiveSearch ? "Apple Maps" : "Sample Data")
            ] + optionalMetadata([
                ("Address", item.address),
                ("Indoor", item.isIndoor.map { $0 ? "Yes" : "No" })
            ]),
            actionTitle: "Open in Maps",
            favoriteID: item.id,
            mapLaunchInfo: makeMapLaunchInfo(latitude: item.latitude, longitude: item.longitude, name: item.title),
            articleURL: nil
        )
    }

    private func optionalMetadata(_ values: [(String, String?)]) -> [DetailMetadata] {
        values.compactMap { label, value in
            guard let value, !value.isEmpty else { return nil }
            return DetailMetadata(label: label, value: value)
        }
    }

    private func makeMapLaunchInfo(latitude: Double?, longitude: Double?, name: String) -> MapLaunchInfo? {
        guard let latitude, let longitude else { return nil }
        return MapLaunchInfo(latitude: latitude, longitude: longitude, name: name)
    }
}
