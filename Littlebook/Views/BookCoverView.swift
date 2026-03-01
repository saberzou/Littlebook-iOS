import SwiftUI

/// A 3D book cover that:
///   • Renders a realistic book shape (spine + cover face + page edge)
///   • Reacts to device gyroscope tilt (via BookMotionManager)
///   • Lets the user spin the book by dragging horizontally
///   • Applies a Metal specular highlight on iOS 17+ (gradient fallback on iOS 16)
///   • Double-tap resets spin back to neutral
///   • Uses ContentStore.coverURL() for multi-API cover resolution
struct BookCoverView: View {
    let isbn: String
    let title: String
    let author: String
    var width: CGFloat = 160
    var height: CGFloat = 240

    @EnvironmentObject var store: ContentStore

    // MARK: - State
    @StateObject private var motion = BookMotionManager()
    @GestureState private var dragDelta: Double = 0
    @State private var baseAngle: Double = 0
    @State private var resolvedURL: URL?
    @State private var isLoadingCover = true

    // MARK: - Geometry
    private var spineWidth: CGFloat { width * 0.12 }
    private var edgeWidth: CGFloat  { width * 0.04 }
    private var coverWidth: CGFloat { width - spineWidth - edgeWidth }

    // MARK: - Rotation
    private var totalRotation: Double {
        (baseAngle + dragDelta + motion.roll * 20).clamped(to: -80...80)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Dynamic shadow beneath the book
            Ellipse()
                .fill(.black.opacity(0.40))
                .frame(width: width * 0.80, height: 14)
                .blur(radius: 9)
                .offset(x: totalRotation * 0.22, y: height / 2 + 10)
                .animation(.linear(duration: 0), value: totalRotation)

            bookBody
                .rotation3DEffect(
                    .degrees(totalRotation),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .center,
                    perspective: 0.4
                )
        }
        .gesture(spinGesture)
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                baseAngle = 0
            }
        }
        .onAppear  { motion.start() }
        .onDisappear { motion.stop() }
        .task(id: isbn) {
            isLoadingCover = true
            resolvedURL = await store.coverURL(for: isbn)
            isLoadingCover = false
        }
    }

    // MARK: - Book Geometry
    private var bookBody: some View {
        ZStack {
            HStack(spacing: 0) {
                spineView
                coverView
                pageEdgeView
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 3))

            // Moving specular gradient (visible on spine/edge and as iOS 16 fallback on cover)
            specularGradient
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .allowsHitTesting(false)
        }
    }

    private var spineView: some View {
        LinearGradient(
            colors: [Color(white: 0.08), Color(white: 0.20), Color(white: 0.13)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: spineWidth, height: height)
    }

    private var coverView: some View {
        ZStack {
            if isLoadingCover {
                coverPlaceholder
                    .shimmer(isActive: true)
            } else if let url = resolvedURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: coverWidth, height: height)
                            .clipped()
                            // Metal specular shader disabled until Metal Toolchain
                            // is installed (Xcode → Settings → Components).
                            // The specularGradient overlay provides the same effect.
                    default:
                        coverPlaceholder
                    }
                }
                .id(isbn)
            } else {
                coverPlaceholder
            }
        }
        .frame(width: coverWidth, height: height)
    }

    private var coverPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.13), Color(white: 0.09)],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                Text(author)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(8)
        }
        .frame(width: coverWidth, height: height)
    }

    private var pageEdgeView: some View {
        ZStack {
            Color(white: 0.90)
            LinearGradient(
                colors: [Color(white: 0.45).opacity(0.45), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .frame(width: edgeWidth, height: height)
    }

    private var specularGradient: some View {
        let norm   = totalRotation / 75.0
        let center = 0.30 + norm * 0.28
        return LinearGradient(
            stops: [
                .init(color: .clear,               location: max(0,   center - 0.28)),
                .init(color: .white.opacity(0.13), location: center),
                .init(color: .clear,               location: min(1.0, center + 0.28)),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Drag Gesture
    private var spinGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($dragDelta) { value, state, _ in
                let h = abs(value.translation.width)
                let v = abs(value.translation.height)
                guard h > v else { return }
                state = value.translation.width / 3.0
            }
            .onEnded { value in
                let h = abs(value.translation.width)
                let v = abs(value.translation.height)
                guard h > v else { return }
                withAnimation(.spring(response: 0.40, dampingFraction: 0.72)) {
                    baseAngle = (baseAngle + value.translation.width / 3.0)
                        .clamped(to: -75...75)
                }
            }
    }
}

// MARK: - Clamping Helper
private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, self))
    }
}
