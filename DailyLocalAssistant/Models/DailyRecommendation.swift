import Foundation

struct DailyRecommendation: Identifiable, Hashable {
    let id = UUID()
    let summary: String
    let focus: String
    let detail: String
}
