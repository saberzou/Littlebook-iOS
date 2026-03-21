import SwiftUI
import WidgetKit

struct LittlebookWidgetEntryView: View {
    var entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1a1a1a"), Color(hex: "#2d2d2d")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                // Header with app branding
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(Color(hex: "#F8705E"))
                        .font(.system(size: headerIconSize))

                    Text("Littlebook")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: headerTextSize, weight: .semibold))
                        .tracking(1)

                    Spacer()

                    if family != .systemSmall {
                        Text(entry.category)
                            .foregroundColor(Color(hex: "#F8705E"))
                            .font(.system(size: categoryTextSize, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, family == .systemSmall ? 8 : 12)

                // Quote content
                VStack(alignment: .leading, spacing: quoteSpacing) {
                    Text(entry.quote)
                        .foregroundColor(.white)
                        .font(.system(size: quoteTextSize, design: .serif))
                        .italic()
                        .lineLimit(family == .systemSmall ? 4 : nil)
                        .multilineTextAlignment(.leading)

                    Text("— \(entry.source)")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: sourceTextSize, weight: .medium))
                        .lineLimit(1)

                    if family == .systemLarge {
                        Spacer(minLength: 8)

                        HStack {
                            Text("From: \(entry.bookTitle)")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(family == .systemSmall ? 12 : 16)
        }
    }

    // Dynamic sizing based on widget family
    private var headerIconSize: CGFloat {
        switch family {
        case .systemSmall: return 12
        case .systemMedium: return 14
        case .systemLarge: return 16
        default: return 14
        }
    }

    private var headerTextSize: CGFloat {
        switch family {
        case .systemSmall: return 10
        case .systemMedium: return 12
        case .systemLarge: return 14
        default: return 12
        }
    }

    private var categoryTextSize: CGFloat {
        switch family {
        case .systemMedium: return 9
        case .systemLarge: return 10
        default: return 9
        }
    }

    private var quoteTextSize: CGFloat {
        switch family {
        case .systemSmall: return 13
        case .systemMedium: return 15
        case .systemLarge: return 17
        default: return 15
        }
    }

    private var sourceTextSize: CGFloat {
        switch family {
        case .systemSmall: return 10
        case .systemMedium: return 11
        case .systemLarge: return 12
        default: return 11
        }
    }

    private var quoteSpacing: CGFloat {
        switch family {
        case .systemSmall: return 6
        case .systemMedium: return 8
        case .systemLarge: return 10
        default: return 8
        }
    }
}

// Widget preview
struct LittlebookWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = QuoteEntry(
            date: Date(),
            quote: "In the midst of chaos, there is also opportunity.",
            source: "Sun Tzu",
            bookTitle: "The Art of War",
            category: "Strategy"
        )

        Group {
            LittlebookWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")

            LittlebookWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")

            LittlebookWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }
}