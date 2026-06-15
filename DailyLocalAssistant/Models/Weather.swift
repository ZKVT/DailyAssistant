import Foundation

struct Weather: Identifiable, Hashable {
    let id = UUID()
    let temperature: Int
    let condition: String
    let rainChance: Int
    let suggestion: String
    let symbolName: String
}
