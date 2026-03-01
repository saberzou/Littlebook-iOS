import Foundation

struct DailyContent: Codable, Identifiable {
    var id: String { date }
    let date: String
    let book: Book
    let wallpaper: Wallpaper?
    let quote: Quote
    let podcast: Podcast?   // nil for dates before the podcast feature launched
}

struct Podcast: Codable {
    /// HTTPS URL to the pre-generated .mp3 file on the CDN
    let audioURL: String
    /// Duration in seconds — pre-seeded from JSON so the progress bar renders before AVPlayer loads
    let duration: Int
    /// Full spoken-word transcript of the episode (accessibility + script accordion)
    let script: String
    /// One-sentence hook shown in the player UI before playback starts
    let teaser: String

    var resolvedAudioURL: URL? { URL(string: audioURL) }
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
