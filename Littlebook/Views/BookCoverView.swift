import SwiftUI

/// A 3D book cover widget that:
///   • Renders a realistic book shape (spine + cover + page edge) from an ISBN
///   • Reacts to device gyroscope tilt (via BookMotionManager)
///   • Lets the user spin the book by dragging horizontally
///   • Applies a Metal specular highlight on iOS 17+ (gradient fallback on iOS 16)
///   • Double-tap resets spin back to neutral
struct BookCoverView: View {
    let isbn: String
    let title: String
    let author: String
    var width: CGFloat = 160
    var height: CGFloat = 240

    // MARK: - State
    @StateObject private var motion = BookMotionManager()
    /// Live horizontal drag delta (resets to 0 when gesture ends)
    @GestureState private var dragDelta: Double = 0
    /// Accumulated angle from completed drag gestures
    @State private var baseAngle: Double = 0

    // MARK: - Geometry Constants
    private var spineWidth: CGFloat { width * 0.12 }   // ~19 pt
    private var edgeWidth: CGFloat  { width * 0.04 }   // ~6 pt
    private var coverWidth: CGFloat { width - spineWidth - edgeWidth }

    // MARK: - Computed Rotation
    /// Total Y-axis rotation: user drag + gyroscope tilt contribution
    private var totalRotation: Double {
        (baseAngle + dragDelta + motion.roll * 20).clamped(to: -80...80)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Oval shadow beneath the book — shifts with rotation for depth cue
            Ellipse()
                .fill(.black.opacity(0.40))
                .frame(width: width * 0.80, height: 14)
                .blur(radius: 9)
                .offset(x: totalRotation * 0.22, y: height / 2 + 10)
                .animation(.linear(duration: 0), value: totalRotation)

            // Book body (spine + cover + page edge) with perspective rotation
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

            // Gradient specular overlay — visible on iOS 16 or whenever
            // the Metal shader isn't applied (e.g., placeholder state)
            specularGradient
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .allowsHitTesting(false)
        }
    }

    /// Narrow dark strip representing the spine (left side of book)
    private var spineView: some View {
        LinearGradient(
            colors: [Color(white: 0.08), Color(white: 0.20), Color(white: 0.13)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: spineWidth, height: height)
    }

    /// Main cover face — async book cover image or fallback placeholder
    private var coverView: some View {
        AsyncImage(
            url: URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg?default=false")
        ) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: coverWidth, height: height)
                    .clipped()
                    // Metal specular highlight (iOS 17+), no-op on iOS 16
                    .metalSpecular(
                        rotation: totalRotation,
                        size: CGSize(width: coverWidth, height: height)
                    )
            default:
                coverPlaceholder
            }
        }
        .frame(width: coverWidth, height: height)
    }

    /// Shown when the cover image is loading or unavailable
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

    /// Thin cream-white strip representing the page edges (right side of book)
    private var pageEdgeView: some View {
        ZStack {
            Color(white: 0.90)
            // Inner shadow on the leading edge to suggest page depth
            LinearGradient(
                colors: [Color(white: 0.45).opacity(0.45), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .frame(width: edgeWidth, height: height)
    }

    /// Moving gradient that simulates a specular sheen shifting with rotation.
    /// This is the iOS 16 fallback; on iOS 17+ the Metal shader takes over for
    /// the cover image, and this gradient provides the same effect on the spine/edge.
    private var specularGradient: some View {
        let norm   = totalRotation / 75.0        // −1 … +1
        let center = 0.30 + norm * 0.28          // shifts 0.02 → 0.58
        return LinearGradient(
            stops: [
                .init(color: .clear,                     location: max(0,   center - 0.28)),
                .init(color: .white.opacity(0.13),        location: center),
                .init(color: .clear,                     location: min(1.0, center + 0.28)),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Drag Gesture
    private var spinGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($dragDelta) { value, state, _ in
                // Only count primarily-horizontal movement so vertical
                // scrolling inside the parent ScrollView isn't hijacked.
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

// MARK: - Metal Specular Modifier
extension View {
    /// Applies a per-pixel Metal specular shader (iOS 17+).
    /// On iOS 16 the caller's gradient overlay provides the same visual cue.
    @ViewBuilder
    func metalSpecular(rotation: Double, size: CGSize) -> some View {
        if #available(iOS 17, *) {
            self.colorEffect(
                ShaderLibrary.bookSpecular(
                    .float2(Float(size.width), Float(size.height)),
                    .float(Float(rotation * .pi / 180.0))
                )
            )
        } else {
            self
        }
    }
}

// MARK: - Clamping Helper
private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, self))
    }
}
