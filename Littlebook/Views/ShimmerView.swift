import SwiftUI

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white.opacity(0.3), location: 0.4),
                                .init(color: .white.opacity(0.5), location: 0.5),
                                .init(color: .white.opacity(0.3), location: 0.6),
                                .init(color: .clear, location: 1),
                            ],
                            startPoint: .init(x: phase - 0.5, y: 0),
                            endPoint: .init(x: phase + 0.5, y: 0)
                        )
                    }
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1.5
                    }
                }
                .mask(content)
        } else {
            content
        }
    }
}

extension View {
    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}
