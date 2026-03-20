import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedTab: FavoriteTab = .quotes
    @State private var searchText = ""

    enum FavoriteTab: CaseIterable {
        case quotes, books, wallpapers

        var title: String {
            switch self {
            case .quotes: return "Quotes"
            case .books: return "Books"
            case .wallpapers: return "Wallpapers"
            }
        }

        var icon: String {
            switch self {
            case .quotes: return "quote.opening"
            case .books: return "book.fill"
            case .wallpapers: return "photo"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom tab selector
                HStack(spacing: 0) {
                    ForEach(FavoriteTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 16, weight: .medium))
                                Text(tab.title)
                                    .font(.system(size: 16, weight: .medium))

                                // Count badge
                                Text("\(countForTab(tab))")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "#F8705E"))
                                    .cornerRadius(8)
                            }
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == tab ?
                                Color.primary.opacity(0.1) :
                                Color.clear
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Divider()

                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .quotes:
                        FavoriteQuotesView(searchText: searchText)
                    case .books:
                        FavoriteBooksView(searchText: searchText)
                    case .wallpapers:
                        FavoriteWallpapersView(searchText: searchText)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search favorites...")
            .overlay {
                if favoritesManager.totalFavorites == 0 {
                    EmptyFavoritesView()
                }
            }
        }
    }

    private func countForTab(_ tab: FavoriteTab) -> Int {
        switch tab {
        case .quotes: return favoritesManager.favoriteQuotes.count
        case .books: return favoritesManager.favoriteBooks.count
        case .wallpapers: return favoritesManager.favoriteWallpapers.count
        }
    }
}

struct FavoriteQuotesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    let searchText: String

    private var filteredQuotes: [FavoriteQuote] {
        let quotes = favoritesManager.getFavoriteQuotes()
        if searchText.isEmpty {
            return quotes
        }
        return quotes.filter {
            $0.quote.text.localizedCaseInsensitiveContains(searchText) ||
            $0.quote.source.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredQuotes) { favoriteQuote in
                    QuoteFavoriteCard(favoriteQuote: favoriteQuote)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct FavoriteBooksView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    let searchText: String

    private var filteredBooks: [FavoriteBook] {
        let books = favoritesManager.getFavoriteBooks()
        if searchText.isEmpty {
            return books
        }
        return books.filter {
            $0.book.title.localizedCaseInsensitiveContains(searchText) ||
            $0.book.author.localizedCaseInsensitiveContains(searchText) ||
            $0.book.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredBooks) { favoriteBook in
                    BookFavoriteCard(favoriteBook: favoriteBook)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct FavoriteWallpapersView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    let searchText: String

    private var filteredWallpapers: [FavoriteWallpaper] {
        let wallpapers = favoritesManager.getFavoriteWallpapers()
        if searchText.isEmpty {
            return wallpapers
        }
        return wallpapers.filter {
            $0.wallpaper.user.localizedCaseInsensitiveContains(searchText) ||
            $0.date.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 16) {
                ForEach(filteredWallpapers) { favoriteWallpaper in
                    WallpaperFavoriteCard(favoriteWallpaper: favoriteWallpaper)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Individual Cards
struct QuoteFavoriteCard: View {
    let favoriteQuote: FavoriteQuote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formattedDate(favoriteQuote.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    // Remove from favorites
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(Color(hex: "#F8705E"))
                }
            }

            Text("\"\(favoriteQuote.quote.text)\"")
                .font(.system(size: 16, design: .serif))
                .italic()
                .multilineTextAlignment(.leading)

            Text("— \(favoriteQuote.quote.source)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private func formattedDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct BookFavoriteCard: View {
    let favoriteBook: FavoriteBook

    var body: some View {
        HStack(spacing: 12) {
            // Book cover placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 80)
                .overlay(
                    Image(systemName: "book.fill")
                        .foregroundColor(.gray)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(favoriteBook.book.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)

                Text(favoriteBook.book.author)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text(favoriteBook.book.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#F8705E").opacity(0.2))
                    .cornerRadius(6)

                Spacer()
            }

            Spacer()

            Button {
                // Remove from favorites
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundColor(Color(hex: "#F8705E"))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct WallpaperFavoriteCard: View {
    let favoriteWallpaper: FavoriteWallpaper

    var body: some View {
        ZStack {
            if let url = favoriteWallpaper.wallpaper.portraitURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
            }

            // Overlay with info
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(favoriteWallpaper.wallpaper.user)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text(formattedDate(favoriteWallpaper.date))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Button {
                        // Remove from favorites
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(hex: "#F8705E"))
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .aspectRatio(3/4, contentMode: .fit)
        .cornerRadius(12)
        .clipped()
    }

    private func formattedDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))

            VStack(spacing: 8) {
                Text("No Favorites Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Tap the heart icon on quotes, books, and wallpapers to save them here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(FavoritesManager.shared)
    }
}