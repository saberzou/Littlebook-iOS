import Foundation

@MainActor
class ContentStore: ObservableObject {
    @Published var items: [DailyContent] = []
    @Published var isLoading = false
    @Published var error: String?

    private let remoteURL = URL(string: "https://raw.githubusercontent.com/saberzou/Littlebook-iOS/main/daily-data.json")!
    private var coverCache: [String: URL] = [:]

    var today: DailyContent? {
        let dateStr = Self.dateString(from: Date())
        return items.first { $0.date == dateStr } ?? items.last
    }

    func item(for date: String) -> DailyContent? {
        items.first { $0.date == date }
    }

    func adjacentDate(from current: String, direction: Int) -> String? {
        guard let idx = items.firstIndex(where: { $0.date == current }) else { return nil }
        let newIdx = idx + direction
        guard newIdx >= 0 && newIdx < items.count else { return nil }
        return items[newIdx].date
    }

    func isTomorrow(_ dateStr: String) -> Bool {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        guard let date = f.date(from: dateStr) else { return false }
        return Calendar.current.isDateInTomorrow(date)
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            items = try JSONDecoder().decode([DailyContent].self, from: data)
        } catch {
            if let url = Bundle.main.url(forResource: "daily-data", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([DailyContent].self, from: data) {
                items = decoded
            } else {
                self.error = "Failed to load content"
            }
        }
    }

    func coverURL(for isbn: String) async -> URL? {
        if let cached = coverCache[isbn] { return cached }

        // 1. Try Open Library
        if let url = await openLibraryCover(isbn: isbn) {
            coverCache[isbn] = url
            return url
        }

        // 2. Fallback: Google Books
        if let url = await googleBooksCover(isbn: isbn) {
            coverCache[isbn] = url
            return url
        }

        return nil
    }

    private func openLibraryCover(isbn: String) async -> URL? {
        let candidates = [isbn, isbn10(from: isbn)].compactMap { $0 }
        for candidate in candidates {
            guard let url = URL(string: "https://covers.openlibrary.org/b/isbn/\(candidate)-L.jpg?default=false") else { continue }
            var req = URLRequest(url: url)
            req.httpMethod = "HEAD"
            if let (_, response) = try? await URLSession.shared.data(for: req),
               let http = response as? HTTPURLResponse, http.statusCode == 200 {
                return url
            }
        }
        return nil
    }

    private func googleBooksCover(isbn: String) async -> URL? {
        guard let apiURL = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: apiURL) else { return nil }

        struct Response: Decodable {
            struct Item: Decodable {
                struct VolumeInfo: Decodable {
                    struct ImageLinks: Decodable {
                        let thumbnail: String?
                    }
                    let imageLinks: ImageLinks?
                }
                let volumeInfo: VolumeInfo
            }
            let items: [Item]?
        }

        guard let response = try? JSONDecoder().decode(Response.self, from: data),
              let thumbnail = response.items?.first?.volumeInfo.imageLinks?.thumbnail else { return nil }

        var urlStr = thumbnail
            .replacingOccurrences(of: "http://", with: "https://")
            .replacingOccurrences(of: "zoom=1", with: "zoom=3")
        return URL(string: urlStr)
    }

    private func isbn10(from isbn13: String) -> String? {
        guard isbn13.count == 13, isbn13.hasPrefix("978") else { return nil }
        let core = String(isbn13.dropFirst(3).dropLast())
        var sum = 0
        for (i, ch) in core.enumerated() {
            guard let digit = ch.wholeNumberValue else { return nil }
            sum += digit * (10 - i)
        }
        let check = (11 - (sum % 11)) % 11
        let checkStr = check == 10 ? "X" : "\(check)"
        return core + checkStr
    }

    static func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f.string(from: date)
    }
}
