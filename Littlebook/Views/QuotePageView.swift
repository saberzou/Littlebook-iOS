import SwiftUI

struct QuotePageView: View {
    let item: DailyContent

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

            ShareLink(
                item: shareText,
                subject: Text("Daily Quote"),
                message: Text("")
            ) {
                Label("Share Quote", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(24)
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
