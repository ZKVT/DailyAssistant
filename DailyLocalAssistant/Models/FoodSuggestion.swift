import Foundation

struct FoodSuggestion: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let distance: String
    let rating: String
    let note: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let phoneNumber: String?
    let mapItemName: String?
    let isFromLiveSearch: Bool

    init(
        id: String,
        name: String,
        category: String,
        distance: String,
        rating: String,
        note: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        phoneNumber: String? = nil,
        mapItemName: String? = nil,
        isFromLiveSearch: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.distance = distance
        self.rating = rating
        self.note = note
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.phoneNumber = phoneNumber
        self.mapItemName = mapItemName
        self.isFromLiveSearch = isFromLiveSearch
    }
}
