import SwiftUI

struct QuotePageView: View {
    let item: DailyContent
    @State private var generatedImage: UIImage?
    @State private var isGeneratingImage = false
    @State private var shareAsImage = true
    @EnvironmentObject var favoritesManager: FavoritesManager

    private var shareText: String {
        "\"\(item.quote.text)\"\n\n— \(item.quote.source)"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(hex: "#FEEAE8"))
                    .frame(height: 60)
                    .padding(.bottom, -20)

                Text(item.quote.text)
                    .font(.system(size: 22, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)

                Text("— \(item.quote.source)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                // Favorite button
                Button {
                    favoritesManager.toggleQuoteFavorite(date: item.date, quote: item.quote)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: favoritesManager.isQuoteFavorite(date: item.date, quote: item.quote) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isQuoteFavorite(date: item.date, quote: item.quote) ? Color(hex: "#F8705E") : .white)
                        Text(favoritesManager.isQuoteFavorite(date: item.date, quote: item.quote) ? "Favorited" : "Add to Favorites")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                }

                // Share mode toggle
                HStack(spacing: 16) {
                    Button {
                        shareAsImage = false
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "text.quote")
                            Text("Text")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(shareAsImage ? .secondary : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(shareAsImage ? Color.white.opacity(0.1) : Color.white.opacity(0.2))
                        .cornerRadius(16)
                    }

                    Button {
                        shareAsImage = true
                        if generatedImage == nil {
                            generateQuoteImage()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                            Text("Image")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(shareAsImage ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(shareAsImage ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .opacity(0.8)

                // Share button
                if shareAsImage {
                    if let image = generatedImage {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("Daily Quote", image: Image(uiImage: image))) {
                            shareButtonContent(isLoading: false, iconName: "photo", text: "Share Image")
                        }
                    } else {
                        Button {
                            generateQuoteImage()
                        } label: {
                            shareButtonContent(isLoading: isGeneratingImage, iconName: "photo", text: isGeneratingImage ? "Generating..." : "Generate Image")
                        }
                        .disabled(isGeneratingImage)
                    }
                } else {
                    ShareLink(
                        item: shareText,
                        subject: Text("Daily Quote"),
                        message: Text("")
                    ) {
                        shareButtonContent(isLoading: false, iconName: "square.and.arrow.up", text: "Share Quote")
                    }
                }
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if shareAsImage && generatedImage == nil {
                generateQuoteImage()
            }
        }
    }

    @ViewBuilder
    private func shareButtonContent(isLoading: Bool, iconName: String, text: String) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
            } else {
                Image(systemName: iconName)
            }
            Text(text)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(24)
    }

    private func generateQuoteImage() {
        isGeneratingImage = true

        Task { @MainActor in
            let image = await Task.detached {
                QuoteImageGenerator.generateQuoteImage(
                    quote: item.quote.text,
                    source: item.quote.source
                )
            }.value

            generatedImage = image
            isGeneratingImage = false
        }
    }
}
