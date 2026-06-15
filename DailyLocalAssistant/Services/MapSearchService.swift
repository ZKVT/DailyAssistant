import CoreLocation
import Foundation
import MapKit

struct MapSearchService {
    private let searchRadius: CLLocationDistance = 8_000
    private let resultLimit = 3

    func fetchNearbyFood(from location: CLLocation) async -> [FoodSuggestion] {
        let queries = ["restaurants", "cafes"]
        let mapItems = await search(queries: queries, near: location)

        guard !mapItems.isEmpty else {
            return MockDailyData.foodSuggestions
        }

        return mapItems.prefix(resultLimit).enumerated().map { index, item in
            makeFoodSuggestion(from: item, userLocation: location, index: index)
        }
    }

    func fetchNearbyActivities(from location: CLLocation, weather: Weather) async -> [ActivitySuggestion] {
        let queries = activityQueries(for: weather)
        let mapItems = await search(queries: queries, near: location)

        guard !mapItems.isEmpty else {
            return MockDailyData.activities
        }

        return mapItems.prefix(resultLimit).enumerated().map { index, item in
            makeActivitySuggestion(from: item, userLocation: location, index: index, weather: weather)
        }
    }

    private func search(queries: [String], near location: CLLocation) async -> [MKMapItem] {
        var uniqueItems: [String: MKMapItem] = [:]

        for query in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: searchRadius,
                longitudinalMeters: searchRadius
            )
            request.resultTypes = .pointOfInterest

            do {
                let response = try await MKLocalSearch(request: request).start()
                for item in response.mapItems {
                    let key = stableID(for: item, fallback: uniqueItems.count)
                    uniqueItems[key] = item
                }
            } catch {
                continue
            }
        }

        return Array(uniqueItems.values)
            .sorted { lhs, rhs in
                distance(from: location, to: lhs) < distance(from: location, to: rhs)
            }
    }

    private func makeFoodSuggestion(from item: MKMapItem, userLocation: CLLocation, index: Int) -> FoodSuggestion {
        let coordinate = item.placemark.coordinate
        let category = categoryName(for: item.pointOfInterestCategory) ?? "Restaurant"

        return FoodSuggestion(
            id: "maps-food-\(stableID(for: item, fallback: index))",
            name: item.name ?? "Nearby Food Spot",
            category: category,
            distance: formattedDistance(from: userLocation, to: item),
            rating: "Maps",
            note: "A nearby option found with Apple Maps local search.",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: address(for: item),
            phoneNumber: item.phoneNumber,
            mapItemName: item.name,
            isFromLiveSearch: true
        )
    }

    private func makeActivitySuggestion(from item: MKMapItem, userLocation: CLLocation, index: Int, weather: Weather) -> ActivitySuggestion {
        let coordinate = item.placemark.coordinate
        let category = categoryName(for: item.pointOfInterestCategory) ?? "Local Attraction"
        let indoor = isIndoorCategory(category) || weather.rainChance > 60 || weather.temperature < 5

        return ActivitySuggestion(
            id: "maps-activity-\(stableID(for: item, fallback: index))",
            title: item.name ?? "Nearby Activity",
            locationHint: category,
            duration: formattedDistance(from: userLocation, to: item),
            note: indoor ? "A nearby indoor-friendly option found with Apple Maps." : "A nearby outdoor-friendly option found with Apple Maps.",
            symbolName: symbolName(for: category, isIndoor: indoor),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: address(for: item),
            category: category,
            isIndoor: indoor,
            isFromLiveSearch: true
        )
    }

    private func activityQueries(for weather: Weather) -> [String] {
        if weather.rainChance > 60 {
            return ["malls", "museums", "cafes", "indoor attractions"]
        }

        if weather.temperature < 5 {
            return ["cafes", "malls", "restaurants", "museums"]
        }

        if weather.condition.localizedCaseInsensitiveContains("sunny")
            || weather.condition.localizedCaseInsensitiveContains("clear") {
            return ["parks", "beaches", "walking trails", "viewpoints", "outdoor attractions"]
        }

        return ["cafes", "parks", "malls", "local attractions"]
    }

    private func formattedDistance(from location: CLLocation, to item: MKMapItem) -> String {
        let meters = distance(from: location, to: item)

        if meters >= 1_000 {
            return String(format: "%.1f km", meters / 1_000)
        }

        return "\(Int(meters.rounded())) m"
    }

    private func distance(from location: CLLocation, to item: MKMapItem) -> CLLocationDistance {
        let coordinate = item.placemark.coordinate
        let destination = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: destination)
    }

    private func address(for item: MKMapItem) -> String? {
        let placemark = item.placemark
        let parts = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality
        ].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    private func stableID(for item: MKMapItem, fallback: Int) -> String {
        let name = item.name ?? "item-\(fallback)"
        let address = address(for: item) ?? item.placemark.coordinate.key
        return "\(name)-\(address)"
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: ",", with: "")
    }

    private func categoryName(for category: MKPointOfInterestCategory?) -> String? {
        guard let category else { return nil }
        let rawValue = category.rawValue.lowercased()

        if rawValue.contains("restaurant") {
            return "Restaurant"
        }

        if rawValue.contains("cafe") {
            return "Cafe"
        }

        if rawValue.contains("bakery") {
            return "Bakery"
        }

        if rawValue.contains("park") {
            return "Park"
        }

        if rawValue.contains("museum") {
            return "Museum"
        }

        if rawValue.contains("theater") {
            return "Theater"
        }

        if rawValue.contains("beach") {
            return "Beach"
        }

        if rawValue.contains("store") || rawValue.contains("shop") {
            return "Shopping"
        }

        return "Local Place"
    }

    private func isIndoorCategory(_ category: String) -> Bool {
        ["Cafe", "Restaurant", "Bakery", "Museum", "Theater", "Shopping", "Local Place"].contains(category)
    }

    private func symbolName(for category: String, isIndoor: Bool) -> String {
        switch category {
        case "Park", "Beach":
            return "leaf.fill"
        case "Museum":
            return "building.columns.fill"
        case "Cafe":
            return "cup.and.saucer.fill"
        case "Shopping":
            return "bag.fill"
        default:
            return isIndoor ? "building.2.fill" : "figure.walk"
        }
    }
}

private extension CLLocationCoordinate2D {
    var key: String {
        "\(latitude)-\(longitude)"
    }
}
