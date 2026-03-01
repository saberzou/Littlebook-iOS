import SwiftUI

/// A 3D book view that displays a book cover with realistic depth, spine, and lighting effects
struct Book3DView: View {
    let coverURL: URL?
    let width: CGFloat
    let height: CGFloat
    
    // Perspective and rotation configuration
    private let rotationAngle: Double = 15
    private let spineWidth: CGFloat
    
    init(coverURL: URL?, width: CGFloat = 52, height: CGFloat = 72) {
        self.coverURL = coverURL
        self.width = width
        self.height = height
        self.spineWidth = width * 0.15 // Spine is 15% of cover width
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Back shadow for depth
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.4))
                .frame(width: width, height: height)
                .offset(x: -spineWidth * 0.5, y: 2)
                .blur(radius: 4)
            
            // Spine
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.15),
                            Color(white: 0.25),
                            Color(white: 0.15)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: spineWidth, height: height)
                .cornerRadius(2, corners: [.topLeft, .bottomLeft])
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 1)
                        .offset(x: spineWidth * 0.5 - 0.5),
                    alignment: .leading
                )
            
            // Front cover with 3D rotation
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipped()
                        .overlay(
                            // Subtle highlight for realism
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.black.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(2, corners: [.topRight, .bottomRight])
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: -2, y: 1)
                        
                case .empty:
                    placeholderView
                        .shimmer(isActive: true)
                        
                case .failure:
                    placeholderView
                    
                @unknown default:
                    placeholderView
                }
            }
            .offset(x: spineWidth)
            
            // Page edges for realistic effect
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 2, height: height - 4)
                .offset(x: spineWidth - 1, y: 0)
                .opacity(0.6)
        }
        .frame(width: width + spineWidth, height: height)
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (x: 0, y: 1, z: 0),
            anchor: .leading,
            perspective: 0.5
        )
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color(white: 0.15),
                        Color(white: 0.2),
                        Color(white: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay(
                Image(systemName: "book.closed")
                    .font(.system(size: width * 0.4))
                    .foregroundColor(Color.white.opacity(0.3))
            )
            .cornerRadius(2, corners: [.topRight, .bottomRight])
            .offset(x: spineWidth)
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Preview for testing
#Preview {
    VStack(spacing: 40) {
        Book3DView(coverURL: nil, width: 80, height: 120)
        
        Book3DView(
            coverURL: URL(string: "https://covers.openlibrary.org/b/isbn/9780140328721-L.jpg"),
            width: 80,
            height: 120
        )
    }
    .padding(60)
    .background(Color.black)
}
