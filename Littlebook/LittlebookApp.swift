import SwiftUI

@main
struct LittlebookApp: App {
    @StateObject private var store = ContentStore()

    var body: some Scene {
        WindowGroup {
            DailyView()
                .environmentObject(store)
                .task { await store.load() }
                .preferredColorScheme(.dark)
        }
    }
}
