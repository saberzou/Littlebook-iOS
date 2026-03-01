import Foundation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var genre: String
    var description: String
    var coverColor: String // Hex color for simple cover design
    
    init(id: UUID = UUID(), title: String, author: String, genre: String, description: String, coverColor: String = "4A90E2") {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.description = description
        self.coverColor = coverColor
    }
}

// Sample books for recommendations
extension Book {
    static let samples: [Book] = [
        Book(
            title: "The Midnight Library",
            author: "Matt Haig",
            genre: "Fiction",
            description: "A dazzling novel about all the choices that go into a life well lived.",
            coverColor: "2C3E50"
        ),
        Book(
            title: "Atomic Habits",
            author: "James Clear",
            genre: "Self-Help",
            description: "An easy and proven way to build good habits and break bad ones.",
            coverColor: "E74C3C"
        ),
        Book(
            title: "Project Hail Mary",
            author: "Andy Weir",
            genre: "Science Fiction",
            description: "A lone astronaut must save the earth from disaster in this gripping tale.",
            coverColor: "8E44AD"
        ),
        Book(
            title: "The Song of Achilles",
            author: "Madeline Miller",
            genre: "Historical Fiction",
            description: "A tale of gods, kings, immortal fame and the human heart.",
            coverColor: "D35400"
        ),
        Book(
            title: "Educated",
            author: "Tara Westover",
            genre: "Memoir",
            description: "A memoir about a young woman who leaves her survivalist family and goes on to earn a PhD.",
            coverColor: "16A085"
        )
    ]
}
