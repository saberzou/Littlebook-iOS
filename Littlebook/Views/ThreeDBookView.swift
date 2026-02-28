import SwiftUI

struct ThreeDBookView: View {
    let book: Book
    @EnvironmentObject var store: ContentStore
    @State private var isFlipped = false
    @State private var coverURL: URL?
    @State private var isLoadingCover = true

    private let width: CGFloat = 160
    private let height: CGFloat = 240
    private let spineWidth: CGFloat = 28

    var body: some View {
        ZStack {
            // Front face
            frontFace
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .opacity(isFlipped ? 0 : 1)

            // Back face
            backFace
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(width: width + spineWidth, height: height)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
        .task {
            coverURL = await store.coverURL(for: book.isbn)
            isLoadingCover = false
        }
    }

    private var frontFace: some View {
        HStack(spacing: 0) {
            // Spine
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.15), Color(white: 0.25), Color(white: 0.12)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: spineWidth, height: height)

                Text(book.title)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-90))
                    .frame(width: height - 20, height: spineWidth)
            }

            // Cover
            ZStack {
                if isLoadingCover {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(white: 0.12))
                        .frame(width: width, height: height)
                        .shimmer()
                } else if let url = coverURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width, height: height)
                                .clipped()
                        default:
                            coverPlaceholder
                        }
                    }
                } else {
                    coverPlaceholder
                }
            }
            .frame(width: width, height: height)

            // Page edges
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(white: 0.92))
                        .frame(width: 4, height: height / 8)
                }
            }
            .frame(width: 4)
        }
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.5), radius: 16, x: 8, y: 8)
    }

    private var backFace: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(white: 0.08))
                .frame(width: width + spineWidth, height: height)

            VStack(spacing: 12) {
                Text(book.category.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.orange.opacity(0.8))

                Text(book.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                Text(book.author)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)

                Text(book.desc)
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .padding(.horizontal, 12)
            }
            .padding()
        }
        .shadow(color: .black.opacity(0.5), radius: 16, x: -8, y: 8)
    }

    private var coverPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.1), Color(white: 0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: 8) {
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                Text(book.author)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(12)
        }
    }
}
