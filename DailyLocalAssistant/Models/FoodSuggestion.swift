import Foundation

struct FoodSuggestion: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let distance: String
    let rating: String
    let note: String
}
