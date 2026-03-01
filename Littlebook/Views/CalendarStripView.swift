import SwiftUI

struct CalendarStripView: View {
    @EnvironmentObject var store: ContentStore
    @Binding var selectedDate: String

    private let todayStr = ContentStore.dateString(from: Date())

    private var visibleDates: [String] {
        let all = store.items.map(\.date)
        guard let todayIdx = all.firstIndex(of: todayStr) else {
            return Array(all.suffix(7))
        }
        let start = max(0, todayIdx - 6)
        let end = min(all.count - 1, todayIdx)
        return Array(all[start...end])
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(visibleDates, id: \.self) { date in
                        DateButton(
                            date: date,
                            isSelected: date == selectedDate,
                            isToday: date == todayStr
                        )
                        .onTapGesture { selectedDate = date }
                        .id(date)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .onAppear {
                proxy.scrollTo(selectedDate, anchor: .center)
            }
            .onChange(of: selectedDate) { newDate in
                withAnimation { proxy.scrollTo(newDate, anchor: .center) }
            }
        }
    }
}

private struct DateButton: View {
    let date: String
    let isSelected: Bool
    let isToday: Bool

    private var parsedDate: Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: date)
    }

    private var dayOfWeek: String {
        guard let d = parsedDate else { return "" }
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: d).uppercased()
    }

    private var dayNumber: String {
        guard let d = parsedDate else { return "" }
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: d)
    }

    var body: some View {
        VStack(spacing: 4) {
            if isToday {
                Text("TODAY")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isSelected ? .white : Color(hex: "#F8705E"))
                    .tracking(1)
            } else {
                Text(dayOfWeek)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            Text(dayNumber)
                .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .gray)
        }
        .frame(width: 44, height: 56)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(hex: "#F8705E") : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: "#F8705E").opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}
