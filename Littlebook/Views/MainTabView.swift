import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: ContentStore
    @State private var selectedDate: String = ""
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyView(selectedDate: $selectedDate)
                .tabItem {
                    Label("Today", systemImage: "book.pages")
                }
                .tag(0)

            WeeklyView(selectedDate: $selectedDate, selectedTab: $selectedTab)
                .tabItem {
                    Label("Week", systemImage: "calendar")
                }
                .tag(1)
        }
        .onAppear {
            if selectedDate.isEmpty {
                selectedDate = store.today?.date ?? ""
            }
        }
        .onChange(of: store.items.count) { _ in
            if selectedDate.isEmpty {
                selectedDate = store.today?.date ?? ""
            }
        }
    }
}
