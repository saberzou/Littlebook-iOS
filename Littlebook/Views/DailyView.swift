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
            currentDate = store.today?.date
        }
    }

    private func cardContent(_ item: DailyContent) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Wallpaper
                if let wp = item.wallpaper, let url = wp.portraitURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                                .cornerRadius(16)
                                .overlay(wallpaperOverlay(wp))
                        case .failure:
                            wallpaperPlaceholder()
                        default:
                            wallpaperPlaceholder()
                                .overlay(ProgressView().tint(.white))
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Book section
                VStack(spacing: 16) {
                    Text(item.book.category.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(2)
                        .foregroundColor(.gray)

                    // Book cover
                    AsyncImage(url: URL(string: "https://covers.openlibrary.org/b/isbn/\(item.book.isbn)-L.jpg?default=false")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 240)
                                .cornerRadius(8)
                                .shadow(color: .white.opacity(0.1), radius: 20)
                        default:
                            bookPlaceholder(item.book)
                        }
                    }

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

    private func wallpaperOverlay(_ wp: Wallpaper) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if let creditURL = wp.creditURL {
                    Link(destination: creditURL) {
                        Text("📷 \(wp.user)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(12)
        }
    }

    private func wallpaperPlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 400)
    }

    private func bookPlaceholder(_ book: Book) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(white: 0.1))
            .frame(width: 160, height: 240)
            .overlay(
                VStack(spacing: 8) {
                    Text(book.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    Text(book.author)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
            )
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                if value.translation.width < -threshold {
                    // Swipe left → next
                    if let next = store.adjacentDate(from: currentDate ?? "", direction: 1) {
                        currentDate = next
                    }
                } else if value.translation.width > threshold {
                    // Swipe right → prev
                    if let prev = store.adjacentDate(from: currentDate ?? "", direction: -1) {
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
