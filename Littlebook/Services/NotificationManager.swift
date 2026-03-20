import UserNotifications
import UIKit

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isNotificationsEnabled: Bool = false
    @Published var notificationTime: Date = {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }()

    private let center = UNUserNotificationCenter.current()

    private init() {
        loadNotificationSettings()
    }

    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()

            if granted {
                isNotificationsEnabled = true
                UserDefaults.standard.set(true, forKey: "notifications_enabled")
                await scheduleAllNotifications()
            }
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }

    func updateAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus

        // Update enabled state based on authorization
        switch authorizationStatus {
        case .authorized, .provisional:
            isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        default:
            isNotificationsEnabled = false
            UserDefaults.standard.set(false, forKey: "notifications_enabled")
        }
    }

    func toggleNotifications() async {
        if authorizationStatus == .notDetermined {
            await requestPermission()
        } else if authorizationStatus == .authorized || authorizationStatus == .provisional {
            isNotificationsEnabled.toggle()
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "notifications_enabled")

            if isNotificationsEnabled {
                await scheduleAllNotifications()
            } else {
                await cancelAllNotifications()
            }
        } else {
            // Redirect to settings
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
    }

    func updateNotificationTime(_ newTime: Date) async {
        notificationTime = newTime
        UserDefaults.standard.set(newTime, forKey: "notification_time")

        if isNotificationsEnabled {
            await scheduleAllNotifications()
        }
    }

    private func scheduleAllNotifications() async {
        await cancelAllNotifications()

        guard isNotificationsEnabled else { return }

        // Schedule notifications for the next 30 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for day in 0..<30 {
            guard let targetDate = calendar.date(byAdding: .day, value: day, to: today) else { continue }
            await scheduleNotification(for: targetDate)
        }

        print("Scheduled 30 daily notifications")
    }

    private func scheduleNotification(for date: Date) async {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)

        guard let scheduledDate = calendar.date(bySettingHour: timeComponents.hour ?? 9,
                                              minute: timeComponents.minute ?? 0,
                                              second: 0,
                                              of: date) else { return }

        // Only schedule future notifications
        guard scheduledDate > Date() else { return }

        // Get content for this date
        let content = UNMutableNotificationContent()
        let dateString = ContentStore.dateString(from: date)

        if let dailyContent = SharedDataManager.shared.getContentForDate(date) {
            content.title = "Daily Quote"
            content.body = "\"\(dailyContent.quote.text)\" — \(dailyContent.quote.source)"
            content.subtitle = "From: \(dailyContent.book.title)"
        } else {
            content.title = "Your Daily Inspiration Awaits"
            content.body = "Discover today's quote and book recommendation in Littlebook"
        }

        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "date": dateString,
            "type": "daily_quote"
        ]

        // Create trigger
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        // Create request
        let identifier = "daily_quote_\(dateString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification for \(dateString): \(error)")
        }
    }

    private func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        print("Cancelled all notifications")
    }

    private func loadNotificationSettings() {
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")

        if let savedTime = UserDefaults.standard.object(forKey: "notification_time") as? Date {
            notificationTime = savedTime
        }

        Task {
            await updateAuthorizationStatus()
        }
    }

    func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Handle notification tap - could navigate to specific content
        if let dateString = userInfo["date"] as? String {
            print("User tapped notification for date: \(dateString)")
            // You could post a notification here to update the app's selected date
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowDateFromNotification"),
                object: nil,
                userInfo: ["date": dateString]
            )
        }
    }
}