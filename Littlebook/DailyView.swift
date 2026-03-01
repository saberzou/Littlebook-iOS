import SwiftUI

struct DailyView: View {
    @EnvironmentObject var store: ContentStore
    @State private var showingAllBooks = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let book = store.dailyRecommendation {
                    VStack(spacing: 20) {
                        Text("Today's Recommendation")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                        
                        BookCardView(book: book)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button {
                            showingAllBooks = true
                        } label: {
                            Label("Browse All Books", systemImage: "books.vertical")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                } else {
                    ContentUnavailableView(
                        "No Books Yet",
                        systemImage: "book.closed",
                        description: Text("Add some books to get daily recommendations")
                    )
                }
            }
            .navigationTitle("Littlebook")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAllBooks) {
                BookListView()
            }
        }
    }
}

struct BookCardView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Book cover simulation
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: book.coverColor).gradient)
                    .frame(height: 300)
                
                VStack {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding()
                    
                    Text(book.author)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding()
            }
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.genre)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(book.description)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(4)
            }
            .padding(.horizontal, 4)
        }
    }
}

// Helper to convert hex string to Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255
        )
    }
}

#Preview {
    DailyView()
        .environmentObject(ContentStore())
}
