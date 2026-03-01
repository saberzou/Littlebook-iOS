import SwiftUI

/// Example view demonstrating various Liquid Glass button styles
@available(iOS 26.0, *)
struct LiquidGlassButtonExamples: View {
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient for visual demonstration
            LinearGradient(
                colors: [.blue, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Liquid Glass Button Examples")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                // Standard circular glass button (like settings)
                VStack(spacing: 8) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.primary)
                            .frame(width: 56, height: 56)
                    }
                    .glassEffect(.regular.interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text("Interactive Circle")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Rounded rectangle glass button
                VStack(spacing: 8) {
                    Button {
                        // Action
                    } label: {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Favorite")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text("Rounded Rectangle")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Capsule glass button
                VStack(spacing: 8) {
                    Button {
                        // Action
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("Add New")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text("Capsule Shape")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Multiple buttons with glass effect container
                VStack(spacing: 8) {
                    GlassEffectContainer(spacing: 20) {
                        HStack(spacing: 20) {
                            Button {
                                // Action
                            } label: {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                                    .frame(width: 50, height: 50)
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                            
                            Button {
                                // Action
                            } label: {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                                    .frame(width: 50, height: 50)
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                            
                            Button {
                                // Action
                            } label: {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                                    .frame(width: 50, height: 50)
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                        }
                    }
                    
                    Text("Container with Multiple Buttons")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) {
            Text("Settings")
                .font(.title)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        LiquidGlassButtonExamples()
    } else {
        Text("Liquid Glass requires iOS 26.0 or later")
    }
}
