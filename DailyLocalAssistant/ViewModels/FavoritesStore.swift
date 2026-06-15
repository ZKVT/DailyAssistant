import Combine
import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String>

    private let storageKey = "favoriteItemIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.favoriteIDs = Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    func isFavorite(_ id: String?) -> Bool {
        guard let id else { return false }
        return favoriteIDs.contains(id)
    }

    func toggle(_ id: String?) {
        guard let id else { return }

        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }

        defaults.set(Array(favoriteIDs).sorted(), forKey: storageKey)
    }

    var savedItems: [DetailPage] {
        let foodPages = MockDailyData.foodSuggestions
            .filter { favoriteIDs.contains($0.id) }
            .map { item in
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
                        DetailMetadata(label: "Rating", value: item.rating)
                    ],
                    actionTitle: "Get Directions",
                    favoriteID: item.id
                )
            }

        let activityPages = MockDailyData.activities
            .filter { favoriteIDs.contains($0.id) }
            .map { item in
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
                        DetailMetadata(label: "Weather fit", value: "Check today's conditions")
                    ],
                    actionTitle: "Get Directions",
                    favoriteID: item.id
                )
            }

        let newsPages = MockDailyData.newsItems
            .filter { favoriteIDs.contains($0.id) }
            .map { item in
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

        return foodPages + activityPages + newsPages
    }
}
