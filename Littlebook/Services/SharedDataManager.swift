import Foundation
class SharedDataManager {
    static let shared = SharedDataManager()

    private let appGroupIdentifier = "group.com.saberzou.littlebook"

    private init() {}

    private var sharedContainer: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    private var sharedDataURL: URL? {
        sharedContainer?.appendingPathComponent("daily-data.json")
    }

    func saveDailyContent(_ items: [DailyContent]) {
        guard let url = sharedDataURL else {
            print("Failed to get shared container URL")
            return
        }

        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save to shared container: \(error)")
        }
    }

    func loadDailyContent() -> [DailyContent]? {
        guard let url = sharedDataURL else {
            print("Failed to get shared container URL")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([DailyContent].self, from: data)
            return items
        } catch {
            print("Failed to load from shared container: \(error)")
            return nil
        }
    }

    func getTodayContent() -> DailyContent? {
        guard let items = loadDailyContent() else { return nil }

        let dateStr = ContentStore.dateString(from: Date())
        return items.first { $0.date == dateStr } ?? items.last
    }

    func getContentForDate(_ date: Date) -> DailyContent? {
        guard let items = loadDailyContent() else { return nil }
        let dateStr = ContentStore.dateString(from: date)
        return items.first { $0.date == dateStr }
    }

    func saveLastUpdateTime(_ date: Date = Date()) {
        UserDefaults(suiteName: appGroupIdentifier)?.set(date, forKey: "lastUpdateTime")
    }

    func getLastUpdateTime() -> Date? {
        UserDefaults(suiteName: appGroupIdentifier)?.object(forKey: "lastUpdateTime") as? Date
    }
}
