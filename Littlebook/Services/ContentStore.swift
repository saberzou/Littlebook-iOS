import Foundation

@MainActor
class ContentStore: ObservableObject {
    @Published var items: [DailyContent] = []
    @Published var isLoading = false
    @Published var error: String?

    private let remoteURL = URL(string: "https://raw.githubusercontent.com/saberzou/Littlebook-iOS/main/daily-data.json")!

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

    func load() async {
        isLoading = true
        defer { isLoading = false }

        // Try remote first, fall back to bundle
        do {
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            items = try JSONDecoder().decode([DailyContent].self, from: data)
        } catch {
            // Fallback to bundled data
            if let url = Bundle.main.url(forResource: "daily-data", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([DailyContent].self, from: data) {
                items = decoded
            } else {
                self.error = "Failed to load content"
            }
        }
    }

    static func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f.string(from: date)
    }
}
