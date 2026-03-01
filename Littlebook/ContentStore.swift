import Foundation
import SwiftUI

@MainActor
class ContentStore: ObservableObject {
    @Published var books: [Book] = []
    @Published var dailyRecommendation: Book?
    
    private let savePath = URL.documentsDirectory.appending(path: "books.json")
    
    func load() async {
        do {
            let data = try Data(contentsOf: savePath)
            books = try JSONDecoder().decode([Book].self, from: data)
        } catch {
            // If no saved data, use sample books
            books = Book.samples
        }
        
        // Set daily recommendation
        updateDailyRecommendation()
    }
    
    func save() async {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }
    
    func updateDailyRecommendation() {
        // Use current date as seed for consistent daily recommendation
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysSince1970 = Int(today.timeIntervalSince1970 / 86400)
        
        if !books.isEmpty {
            let index = daysSince1970 % books.count
            dailyRecommendation = books[index]
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        Task {
            await save()
        }
    }
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        Task {
            await save()
        }
    }
}
