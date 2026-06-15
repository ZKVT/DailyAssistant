import Foundation

struct ActivitySuggestion: Identifiable, Hashable {
    let id: String
    let title: String
    let locationHint: String
    let duration: String
    let note: String
    let symbolName: String
}
