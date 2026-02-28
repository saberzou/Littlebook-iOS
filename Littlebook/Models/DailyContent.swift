import Foundation

struct DailyContent: Codable, Identifiable {
    var id: String { date }
    let date: String
    let book: Book
    let wallpaper: Wallpaper?
    let quote: Quote
}

struct Book: Codable {
    let isbn: String
    let title: String
    let author: String
    let category: String
    let desc: String

    var amazonSearchURL: URL? {
        let query = "\(title) \(author)"
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: "https://www.amazon.com/s?k=\(encoded)")
    }
}

struct Wallpaper: Codable {
    let id: String
    let imgBase: String
    let user: String
    let userUrl: String

    var landscapeURL: URL? {
        URL(string: "\(imgBase)?w=1080&q=80")
    }

    var portraitURL: URL? {
        URL(string: "\(imgBase)?w=800&h=1200&fit=crop&crop=center&q=80")
    }

    var creditURL: URL? {
        URL(string: "\(userUrl)?utm_source=littlebook&utm_medium=referral")
    }

    var unsplashURL: URL? {
        URL(string: "https://unsplash.com/photos/\(id)?utm_source=littlebook&utm_medium=referral")
    }
}

struct Quote: Codable {
    let text: String
    let source: String
}
