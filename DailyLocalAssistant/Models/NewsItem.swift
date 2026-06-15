import Foundation

struct NewsItem: Identifiable, Hashable {
    let id: String
    let title: String
    let source: String
    let time: String
    let summary: String
}
