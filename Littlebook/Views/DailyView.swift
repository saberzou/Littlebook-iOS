import SwiftUI

struct DailyView: View {
    @EnvironmentObject var store: ContentStore
    @State private var currentDate: String?
    @GestureState private var dragOffset: CGFloat = 0

    var currentItem: DailyContent? {
        if let date = currentDate { return store.item(for: date) }
        return store.today
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if store.isLoading {
                ProgressView()
                    .tint(.white)
            } else if let item = currentItem {
                cardContent(item)
                    .offset(x: dragOffset)
                    .gesture(swipeGesture)
                    .animation(.spring(response: 0.35), value: currentDate)
            } else {
                Text("No content for today")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            if currentDate == nil {
                currentDate = store.today?.date
            }
        }
        .onChange(of: store.items) { _ in
            if currentDate == nil {
                currentDate = store.today?.date
            }
        }
    }

    private func cardContent(_ item: DailyContent) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Book section
                VStack(spacing: 16) {
                    Text(item.book.category.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(2)
                        .foregroundColor(.gray)

                    // Book cover (3D, gyroscope-reactive)
                    BookCoverView(
                        isbn: item.book.isbn,
                        title: item.book.title,
                        author: item.book.author
                    )

                    Text(item.book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(item.book.author)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(item.book.desc)
                        .font(.body)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Quote
                VStack(spacing: 12) {
                    Text("\"")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange.opacity(0.6))
                        .frame(height: 30)

                    Text(item.quote.text)
                        .font(.body)
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text("— \(item.quote.source)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 20)

                // Date indicator
                Text(formattedDate(item.date))
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                let fromDate = currentDate ?? store.today?.date ?? ""
                if value.translation.width < -threshold {
                    // Swipe left → next
                    if let next = store.adjacentDate(from: fromDate, direction: 1) {
                        currentDate = next
                    }
                } else if value.translation.width > threshold {
                    // Swipe right → prev
                    if let prev = store.adjacentDate(from: fromDate, direction: -1) {
                        currentDate = prev
                    }
                }
            }
    }

    private func formattedDate(_ dateStr: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dateStr) else { return dateStr }
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: date)
    }
}
