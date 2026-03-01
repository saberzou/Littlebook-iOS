import Foundation

struct DailyContent: Codable, Identifiable {
    var id: String { date }
    let date: String
    let book: Book
    let quote: Quote
}

struct Book: Codable {
    let isbn: String
    let title: String
    let author: String
    let category: String
    let desc: String
}

struct Quote: Codable {
    let text: String
    let source: String
}
