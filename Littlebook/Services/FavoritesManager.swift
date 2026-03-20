import Foundation
import SwiftUI

@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published var favoriteQuotes: Set<String> = []
    @Published var favoriteBooks: Set<String> = []
    @Published var favoriteWallpapers: Set<String> = []

    private let quotesKey = "favorite_quotes"
    private let booksKey = "favorite_books"
    private let wallpapersKey = "favorite_wallpapers"

    private init() {
        loadFavorites()
    }

    // MARK: - Quote Favorites
    func toggleQuoteFavorite(date: String, quote: Quote) {
        let quoteId = "\(date)_\(quote.text.prefix(50).hash)"

        if favoriteQuotes.contains(quoteId) {
            favoriteQuotes.remove(quoteId)
        } else {
            favoriteQuotes.insert(quoteId)
            // Save quote details for later retrieval
            saveFavoriteQuoteDetails(id: quoteId, date: date, quote: quote)
        }
        saveFavorites()
    }

    func isQuoteFavorite(date: String, quote: Quote) -> Bool {
        let quoteId = "\(date)_\(quote.text.prefix(50).hash)"
        return favoriteQuotes.contains(quoteId)
    }

    // MARK: - Book Favorites
    func toggleBookFavorite(book: Book) {
        let bookId = book.isbn

        if favoriteBooks.contains(bookId) {
            favoriteBooks.remove(bookId)
        } else {
            favoriteBooks.insert(bookId)
            // Save book details for later retrieval
            saveFavoriteBookDetails(book: book)
        }
        saveFavorites()
    }

    func isBookFavorite(book: Book) -> Bool {
        return favoriteBooks.contains(book.isbn)
    }

    // MARK: - Wallpaper Favorites
    func toggleWallpaperFavorite(date: String, wallpaper: Wallpaper) {
        let wallpaperId = "\(date)_\(wallpaper.id)"

        if favoriteWallpapers.contains(wallpaperId) {
            favoriteWallpapers.remove(wallpaperId)
        } else {
            favoriteWallpapers.insert(wallpaperId)
            // Save wallpaper details for later retrieval
            saveFavoriteWallpaperDetails(id: wallpaperId, date: date, wallpaper: wallpaper)
        }
        saveFavorites()
    }

    func isWallpaperFavorite(date: String, wallpaper: Wallpaper) -> Bool {
        let wallpaperId = "\(date)_\(wallpaper.id)"
        return favoriteWallpapers.contains(wallpaperId)
    }

    // MARK: - Favorite Details Storage
    private func saveFavoriteQuoteDetails(id: String, date: String, quote: Quote) {
        let favoriteQuote = FavoriteQuote(id: id, date: date, quote: quote)
        if let encoded = try? JSONEncoder().encode(favoriteQuote) {
            UserDefaults.standard.set(encoded, forKey: "quote_\(id)")
        }
    }

    private func saveFavoriteBookDetails(book: Book) {
        let favoriteBook = FavoriteBook(book: book, dateAdded: Date())
        if let encoded = try? JSONEncoder().encode(favoriteBook) {
            UserDefaults.standard.set(encoded, forKey: "book_\(book.isbn)")
        }
    }

    private func saveFavoriteWallpaperDetails(id: String, date: String, wallpaper: Wallpaper) {
        let favoriteWallpaper = FavoriteWallpaper(id: id, date: date, wallpaper: wallpaper)
        if let encoded = try? JSONEncoder().encode(favoriteWallpaper) {
            UserDefaults.standard.set(encoded, forKey: "wallpaper_\(id)")
        }
    }

    // MARK: - Retrieve Favorites
    func getFavoriteQuotes() -> [FavoriteQuote] {
        return favoriteQuotes.compactMap { id in
            guard let data = UserDefaults.standard.data(forKey: "quote_\(id)"),
                  let favoriteQuote = try? JSONDecoder().decode(FavoriteQuote.self, from: data) else {
                return nil
            }
            return favoriteQuote
        }.sorted { $0.date > $1.date }
    }

    func getFavoriteBooks() -> [FavoriteBook] {
        return favoriteBooks.compactMap { isbn in
            guard let data = UserDefaults.standard.data(forKey: "book_\(isbn)"),
                  let favoriteBook = try? JSONDecoder().decode(FavoriteBook.self, from: data) else {
                return nil
            }
            return favoriteBook
        }.sorted { $0.dateAdded > $1.dateAdded }
    }

    func getFavoriteWallpapers() -> [FavoriteWallpaper] {
        return favoriteWallpapers.compactMap { id in
            guard let data = UserDefaults.standard.data(forKey: "wallpaper_\(id)"),
                  let favoriteWallpaper = try? JSONDecoder().decode(FavoriteWallpaper.self, from: data) else {
                return nil
            }
            return favoriteWallpaper
        }.sorted { $0.date > $1.date }
    }

    // MARK: - Persistence
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteQuotes), forKey: quotesKey)
        UserDefaults.standard.set(Array(favoriteBooks), forKey: booksKey)
        UserDefaults.standard.set(Array(favoriteWallpapers), forKey: wallpapersKey)
    }

    private func loadFavorites() {
        if let quotes = UserDefaults.standard.array(forKey: quotesKey) as? [String] {
            favoriteQuotes = Set(quotes)
        }
        if let books = UserDefaults.standard.array(forKey: booksKey) as? [String] {
            favoriteBooks = Set(books)
        }
        if let wallpapers = UserDefaults.standard.array(forKey: wallpapersKey) as? [String] {
            favoriteWallpapers = Set(wallpapers)
        }
    }

    // MARK: - Statistics
    var totalFavorites: Int {
        favoriteQuotes.count + favoriteBooks.count + favoriteWallpapers.count
    }

    var favoritesBreakdown: (quotes: Int, books: Int, wallpapers: Int) {
        (favoriteQuotes.count, favoriteBooks.count, favoriteWallpapers.count)
    }
}

// MARK: - Data Models
struct FavoriteQuote: Codable, Identifiable {
    let id: String
    let date: String
    let quote: Quote
    let dateAdded: Date

    init(id: String, date: String, quote: Quote) {
        self.id = id
        self.date = date
        self.quote = quote
        self.dateAdded = Date()
    }
}

struct FavoriteBook: Codable, Identifiable {
    var id: String { book.isbn }
    let book: Book
    let dateAdded: Date
}

struct FavoriteWallpaper: Codable, Identifiable {
    let id: String
    let date: String
    let wallpaper: Wallpaper
    let dateAdded: Date

    init(id: String, date: String, wallpaper: Wallpaper) {
        self.id = id
        self.date = date
        self.wallpaper = wallpaper
        self.dateAdded = Date()
    }
}