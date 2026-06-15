import Foundation

struct NewsItem: Identifiable, Hashable {
    let id: String
    let title: String
    let source: String
    let time: String
    let summary: String
    let url: URL?
    let imageURL: URL?
    let publishedAt: Date?
    let sourceName: String
    let isFromLiveSource: Bool

    init(
        id: String,
        title: String,
        source: String,
        time: String,
        summary: String,
        url: URL? = nil,
        imageURL: URL? = nil,
        publishedAt: Date? = nil,
        sourceName: String? = nil,
        isFromLiveSource: Bool = false
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.time = time
        self.summary = summary
        self.url = url
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        self.sourceName = sourceName ?? source
        self.isFromLiveSource = isFromLiveSource
    }
}
