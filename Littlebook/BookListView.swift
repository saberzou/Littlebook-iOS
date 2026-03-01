import SwiftUI

struct BookListView: View {
    @EnvironmentObject var store: ContentStore
    @Environment(\.dismiss) var dismiss
    @State private var showingAddBook = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.books) { book in
                    BookRowView(book: book)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("All Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
        }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            store.deleteBook(store.books[index])
        }
    }
}

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: book.coverColor))
                .frame(width: 50, height: 70)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(book.genre)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BookListView()
        .environmentObject(ContentStore())
}
