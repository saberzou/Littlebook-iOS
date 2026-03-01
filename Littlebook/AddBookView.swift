import SwiftUI

struct AddBookView: View {
    @EnvironmentObject var store: ContentStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""
    @State private var description = ""
    @State private var selectedColor = "4A90E2"
    
    let colorOptions = [
        "4A90E2", // Blue
        "E74C3C", // Red
        "8E44AD", // Purple
        "2ECC71", // Green
        "F39C12", // Orange
        "1ABC9C", // Teal
        "E67E22", // Dark Orange
        "2C3E50", // Dark Blue
        "C0392B", // Dark Red
        "16A085"  // Dark Teal
    ]
    
    var isValid: Bool {
        !title.isEmpty && !author.isEmpty && !genre.isEmpty && !description.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Genre", text: $genre)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                Section("Cover Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    if selectedColor == color {
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 3)
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addBook()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    func addBook() {
        let book = Book(
            title: title,
            author: author,
            genre: genre,
            description: description,
            coverColor: selectedColor
        )
        store.addBook(book)
        dismiss()
    }
}

#Preview {
    AddBookView()
        .environmentObject(ContentStore())
}
