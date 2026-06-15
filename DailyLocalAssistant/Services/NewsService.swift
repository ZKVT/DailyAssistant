import Foundation

struct NewsService {
    private let feedURLs: [URL]
    private let session: URLSession

    init(
        feedURLs: [URL] = [
            URL(string: "https://www.cbc.ca/cmlink/rss-canada-britishcolumbia")!
        ],
        session: URLSession = .shared
    ) {
        self.feedURLs = feedURLs
        self.session = session
    }

    func fetchLocalNews(near locationName: String) async -> [NewsItem] {
        guard !feedURLs.isEmpty else {
            return MockDailyData.newsItems
        }

        for feedURL in feedURLs {
            do {
                let items = try await fetchRSSItems(from: feedURL, sourceName: sourceName(for: feedURL))
                if !items.isEmpty {
                    return Array(items.prefix(5))
                }
            } catch {
                continue
            }
        }

        return MockDailyData.newsItems
    }

    private func fetchRSSItems(from url: URL, sourceName: String) async throws -> [NewsItem] {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let parserDelegate = RSSParserDelegate(sourceName: sourceName)
        let parser = XMLParser(data: data)
        parser.delegate = parserDelegate

        guard parser.parse() else {
            throw parser.parserError ?? URLError(.cannotParseResponse)
        }

        return parserDelegate.items
    }

    private func sourceName(for url: URL) -> String {
        if let host = url.host {
            return host
                .replacingOccurrences(of: "www.", with: "")
                .replacingOccurrences(of: ".ca", with: "")
                .replacingOccurrences(of: ".com", with: "")
                .uppercased()
        }

        return "Local RSS"
    }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate {
    private(set) var items: [NewsItem] = []

    private let sourceName: String
    private var currentElement = ""
    private var currentText = ""
    private var currentItem: RSSItem?

    init(sourceName: String) {
        self.sourceName = sourceName
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""

        if elementName == "item" || elementName == "entry" {
            currentItem = RSSItem()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let value = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        if var item = currentItem {
            switch elementName {
            case "title":
                item.title = value
            case "link":
                item.link = value
            case "description", "summary":
                item.summary = value.strippedHTML
            case "pubDate", "published", "updated":
                item.publishedAt = Date.rssDate(from: value)
            default:
                break
            }

            currentItem = item
        }

        if elementName == "item" || elementName == "entry" {
            if let newsItem = currentItem?.makeNewsItem(sourceName: sourceName) {
                items.append(newsItem)
            }
            currentItem = nil
        }

        currentText = ""
    }
}

private struct RSSItem {
    var title = ""
    var link = ""
    var summary = ""
    var publishedAt: Date?

    func makeNewsItem(sourceName: String) -> NewsItem? {
        guard !title.isEmpty else { return nil }

        let articleURL = URL(string: link)
        let stableID = articleURL?.absoluteString ?? title
        let publishedLabel = publishedAt?.relativeNewsTime ?? "Recently"

        return NewsItem(
            id: "news-live-\(stableID.hashValue)",
            title: title,
            source: sourceName,
            time: publishedLabel,
            summary: summary.isEmpty ? "Open the full article for more details." : summary,
            url: articleURL,
            publishedAt: publishedAt,
            sourceName: sourceName,
            isFromLiveSource: true
        )
    }
}

private extension String {
    var strippedHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
    }
}

private extension Date {
    static func rssDate(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let formats = [
            "E, d MMM yyyy HH:mm:ss Z",
            "E, dd MMM yyyy HH:mm:ss Z",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }

    var relativeNewsTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
