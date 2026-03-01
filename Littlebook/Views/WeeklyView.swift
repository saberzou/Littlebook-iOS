import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var store: ContentStore
    @EnvironmentObject var theme: ThemeManager
    @Binding var selectedDate: String
    @Binding var selectedTab: Int

    private let todayStr = ContentStore.dateString(from: Date())

    private var weekItems: [DailyContent] {
        let all = store.items
        guard let todayIdx = all.firstIndex(where: { $0.date == todayStr }) else {
            return Array(all.suffix(7))
        }
        let start = max(0, todayIdx - 5)
        let end = min(all.count - 1, todayIdx + 1)
        return Array(all[start...end])
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(weekItems.enumerated()), id: \.element.date) { index, item in
                        BookCard(
                            item: item,
                            dayNumber: index + 1,
                            isToday: item.date == todayStr
                        )
                        .onTapGesture {
                            selectedDate = item.date
                            selectedTab = 0
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("This Week")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { theme.isDark.toggle() }
                    } label: {
                        Image(systemName: theme.isDark ? "sun.max" : "moon")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

private struct BookCard: View {
    let item: DailyContent
    let dayNumber: Int
    let isToday: Bool
    @EnvironmentObject var store: ContentStore
    @State private var coverURL: URL?

    var body: some View {
        HStack(spacing: 16) {
            // Day number
            VStack(spacing: 2) {
                if isToday {
                    Text("TODAY")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.orange)
                        .tracking(1)
                } else {
                    Text(weekdayAbbr(item.date))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Text(String(format: "%02d", dayNumber))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isToday ? .orange : .primary)
            }
            .frame(width: 44)

            // Book cover thumbnail with 3D effect
            Book3DView(coverURL: coverURL, width: 52, height: 72)

            // Book info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.book.category.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(.orange)

                Text(item.book.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                Text(item.book.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: isToday ? 0.12 : 0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isToday ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .task {
            coverURL = await store.coverURL(for: item.book.isbn)
        }
    }

    private func weekdayAbbr(_ dateStr: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dateStr) else { return "" }
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }
}
