import WidgetKit
import SwiftUI

struct LittlebookWidget: Widget {
    let kind: String = "LittlebookWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteTimelineProvider()) { entry in
            LittlebookWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Quote")
        .description("Get inspired with a daily quote from Littlebook.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct QuoteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(
            date: Date(),
            quote: "The only way to do great work is to love what you do.",
            source: "Steve Jobs",
            bookTitle: "Steve Jobs",
            category: "Biography"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let entry = QuoteEntry(
            date: Date(),
            quote: "In the midst of chaos, there is also opportunity.",
            source: "Sun Tzu",
            bookTitle: "The Art of War",
            category: "Strategy"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> ()) {
        Task {
            let entries = await generateEntries()
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

    private func generateEntries() async -> [QuoteEntry] {
        var entries: [QuoteEntry] = []
        let currentDate = Date()

        // Load today's content
        if let todayContent = await loadTodayContent() {
            let entry = QuoteEntry(
                date: currentDate,
                quote: todayContent.quote.text,
                source: todayContent.quote.source,
                bookTitle: todayContent.book.title,
                category: todayContent.book.category
            )
            entries.append(entry)
        } else {
            // Fallback entry
            let fallbackEntry = QuoteEntry(
                date: currentDate,
                quote: "A journey of a thousand miles begins with a single step.",
                source: "Lao Tzu",
                bookTitle: "Tao Te Ching",
                category: "Philosophy"
            )
            entries.append(fallbackEntry)
        }

        // Schedule next update for tomorrow at 6 AM
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate),
           let tomorrowAt6AM = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: tomorrow) {

            if let tomorrowContent = await loadContentForDate(tomorrowAt6AM) {
                let tomorrowEntry = QuoteEntry(
                    date: tomorrowAt6AM,
                    quote: tomorrowContent.quote.text,
                    source: tomorrowContent.quote.source,
                    bookTitle: tomorrowContent.book.title,
                    category: tomorrowContent.book.category
                )
                entries.append(tomorrowEntry)
            }
        }

        return entries
    }

    private func loadTodayContent() async -> DailyContent? {
        return await loadContentForDate(Date())
    }

    private func loadContentForDate(_ date: Date) async -> DailyContent? {
        do {
            // Try to load from shared container first
            if let sharedData = loadSharedData() {
                let dateStr = ContentStore.dateString(from: date)
                return sharedData.first { $0.date == dateStr }
            }

            let items = try await loadRemoteItems()

            let dateStr = ContentStore.dateString(from: date)
            return items.first { $0.date == dateStr } ?? items.last
        } catch {
            return nil
        }
    }

    private func loadSharedData() -> [DailyContent]? {
        guard let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.saberzou.littlebook"),
              let data = try? Data(contentsOf: sharedContainer.appendingPathComponent("daily-data.json")),
              let items = try? JSONDecoder().decode([DailyContent].self, from: data) else {
            return nil
        }
        return items
    }

    private func loadRemoteItems() async throws -> [DailyContent] {
        var snapshots: [RemoteFeedSnapshot] = []

        for source in ContentFeeds.sources {
            var request = URLRequest(url: source.url)
            request.cachePolicy = .reloadIgnoringLocalCacheData

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse,
                      200..<300 ~= http.statusCode else {
                    continue
                }

                let items = try JSONDecoder().decode([DailyContent].self, from: data)
                guard !items.isEmpty else { continue }
                snapshots.append(RemoteFeedSnapshot(source: source, items: items))
            } catch {
                continue
            }
        }

        guard !snapshots.isEmpty else {
            throw URLError(.badServerResponse)
        }

        let mergedItems = snapshots
            .sorted(by: remoteFeedSort)
            .reduce(into: [String: DailyContent]()) { result, snapshot in
                for item in snapshot.items.sorted(by: { $0.date < $1.date }) {
                    result[item.date] = item
                }
            }

        return mergedItems.values.sorted(by: { $0.date < $1.date })
    }

    private struct RemoteFeedSnapshot {
        let source: ContentFeeds.Source
        let items: [DailyContent]

        var latestDate: String {
            items.map(\.date).max() ?? ""
        }
    }

    private func remoteFeedSort(lhs: RemoteFeedSnapshot, rhs: RemoteFeedSnapshot) -> Bool {
        if lhs.latestDate != rhs.latestDate {
            return lhs.latestDate < rhs.latestDate
        }

        if lhs.items.count != rhs.items.count {
            return lhs.items.count < rhs.items.count
        }

        return lhs.source.priority < rhs.source.priority
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let source: String
    let bookTitle: String
    let category: String
}
