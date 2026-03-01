import SwiftUI

struct DailyView: View {
    @EnvironmentObject var store: ContentStore
    @EnvironmentObject var theme: ThemeManager
    @Binding var selectedDate: String
    @State private var activePage: Int = 0

    private var currentItem: DailyContent? {
        store.item(for: selectedDate)
    }

    var body: some View {
        ZStack {
            if store.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let item = currentItem {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(formattedDate(selectedDate))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)

                        Spacer()

                        Button {
                            withAnimation { theme.isDark.toggle() }
                        } label: {
                            Image(systemName: theme.isDark ? "sun.max" : "moon")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                                .frame(width: 36, height: 36)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    // Calendar strip
                    CalendarStripView(selectedDate: $selectedDate)

                    // Page indicator
                    pageIndicator

                    // Content carousel
                    TabView(selection: $activePage) {
                        BookPageView(item: item)
                            .tag(0)
                        QuotePageView(item: item)
                            .tag(1)
                        WallpaperPageView(item: item)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: activePage)
                }
            } else if !store.isLoading {
                Text("No content available")
                    .foregroundColor(.secondary)
            }

            // Tomorrow countdown overlay
            if let item = currentItem, store.isTomorrow(item.date) {
                CountdownOverlayView(targetDate: item.date)
            }
        }
        .onChange(of: selectedDate) { _ in
            activePage = 0
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { idx in
                Capsule()
                    .fill(activePage == idx ? Color.primary : Color.secondary.opacity(0.4))
                    .frame(width: activePage == idx ? 20 : 8, height: 6)
                    .animation(.spring(response: 0.3), value: activePage)
            }
        }
        .padding(.vertical, 8)
    }

    private func formattedDate(_ dateStr: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dateStr) else { return dateStr }
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: date)
    }
}
