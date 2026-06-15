import Foundation

enum MockDailyData {
    static let location = "Richmond, BC"

    static let weather = Weather(
        temperature: 16,
        condition: "Light Rain",
        rainChance: 68,
        suggestion: "Bring an umbrella and choose a cozy indoor stop.",
        symbolName: "cloud.rain.fill"
    )

    static let foodSuggestions = [
        FoodSuggestion(
            id: "food-steveston-seafood-bowl",
            name: "Steveston Seafood Bowl",
            category: "Seafood",
            distance: "3.2 km",
            rating: "4.6",
            note: "A comforting choice for a cooler day, especially if you want something local and filling."
        ),
        FoodSuggestion(
            id: "food-alexandra-road-noodles",
            name: "Alexandra Road Noodles",
            category: "Noodles",
            distance: "1.8 km",
            rating: "4.5",
            note: "Warm broth and quick service make this a strong rainy-day lunch option."
        ),
        FoodSuggestion(
            id: "food-local-bakery-cafe",
            name: "Local Bakery Cafe",
            category: "Cafe",
            distance: "0.9 km",
            rating: "4.4",
            note: "Good for a relaxed coffee break, a pastry, and a short pause between errands."
        )
    ]

    static let newsItems = [
        NewsItem(
            id: "news-community-centre-events",
            title: "Community centre events updated for the week",
            source: "Local Bulletin",
            time: "2h ago",
            summary: "A quick roundup of indoor classes, family programs, and drop-in sessions around Richmond."
        ),
        NewsItem(
            id: "news-transit-service-reminder",
            title: "Transit service reminder for evening commuters",
            source: "Metro Desk",
            time: "4h ago",
            summary: "Expect slightly busier routes near shopping areas during the evening window."
        ),
        NewsItem(
            id: "news-weekend-market-vendors",
            title: "Weekend market vendors announced",
            source: "City Notes",
            time: "6h ago",
            summary: "Food, craft, and produce vendors are scheduled for nearby weekend community markets."
        )
    ]

    static let activities = [
        ActivitySuggestion(
            id: "activity-richmond-centre",
            title: "Visit a nearby mall",
            locationHint: "CF Richmond Centre",
            duration: "60-90 min",
            note: "A low-effort indoor option with food, errands, and a comfortable walking route.",
            symbolName: "bag.fill"
        ),
        ActivitySuggestion(
            id: "activity-central-richmond-cafe",
            title: "Try a local cafe",
            locationHint: "Central Richmond",
            duration: "30-45 min",
            note: "Pick somewhere close, bring a book, and make it a simple daily reset.",
            symbolName: "cup.and.saucer.fill"
        ),
        ActivitySuggestion(
            id: "activity-minoru-park-walk",
            title: "Take a short park walk",
            locationHint: "Minoru Park",
            duration: "20-30 min",
            note: "Best saved for a dry window later in the day. Keep it short and easy.",
            symbolName: "figure.walk"
        )
    ]
}
