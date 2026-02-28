import SwiftUI

struct BookPageView: View {
    let item: DailyContent

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Text(item.book.category.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(2)
                    .foregroundColor(.gray)
                    .padding(.top, 16)

                ThreeDBookView(book: item.book)
                    .padding(.vertical, 8)

                VStack(spacing: 10) {
                    Text(item.book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(item.book.author)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(item.book.desc)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                }

                actionBar

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 20)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            if let url = item.book.amazonSearchURL {
                Link(destination: url) {
                    Label("Buy", systemImage: "bag")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(22)
                }
            }

            ShareLink(
                item: "Check out \"\(item.book.title)\" by \(item.book.author)",
                subject: Text("Book Recommendation"),
                message: Text(item.book.desc)
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(22)
            }
        }
        .padding(.top, 8)
    }
}
