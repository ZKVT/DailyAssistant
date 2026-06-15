import Foundation

struct DetailPage: Identifiable, Hashable {
    let id: String
    let kind: DetailKind
    let title: String
    let subtitle: String
    let symbolName: String
    let accentName: String
    let body: String
    let highlights: [String]
    let metadata: [DetailMetadata]
    let actionTitle: String
    let favoriteID: String?
}
