import SwiftUI

@main
struct LittlebookApp: App {
    @StateObject private var store = ContentStore()
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .environmentObject(theme)
                .preferredColorScheme(theme.colorScheme)
                .task { await store.load() }
        }
    }
}
