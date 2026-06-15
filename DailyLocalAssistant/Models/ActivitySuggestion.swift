import Foundation

struct ActivitySuggestion: Identifiable, Hashable {
    let id: String
    let title: String
    let locationHint: String
    let duration: String
    let note: String
    let symbolName: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let category: String?
    let isIndoor: Bool?
    let isFromLiveSearch: Bool

    init(
        id: String,
        title: String,
        locationHint: String,
        duration: String,
        note: String,
        symbolName: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        category: String? = nil,
        isIndoor: Bool? = nil,
        isFromLiveSearch: Bool = false
    ) {
        self.id = id
        self.title = title
        self.locationHint = locationHint
        self.duration = duration
        self.note = note
        self.symbolName = symbolName
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.category = category
        self.isIndoor = isIndoor
        self.isFromLiveSearch = isFromLiveSearch
    }
}
