import UIKit
import SwiftUI

struct QuoteImageGenerator {
    static func generateQuoteImage(quote: String, source: String) -> UIImage {
        let width: CGFloat = 1080
        let height: CGFloat = 1920
        let size = CGSize(width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.97, green: 0.42, blue: 0.37, alpha: 1.0).cgColor, // #F86B5E
                    UIColor(red: 0.96, green: 0.55, blue: 0.48, alpha: 1.0).cgColor  // Lighter shade
                ] as CFArray,
                locations: [0.0, 1.0]
            )!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: height),
                options: []
            )
            
            // Add some decorative elements
            let padding: CGFloat = 80
            let contentWidth = width - (padding * 2)
            
            // Opening quote mark
            let quoteMarkFont = UIFont.systemFont(ofSize: 120, weight: .bold)
            let quoteMarkAttrs: [NSAttributedString.Key: Any] = [
                .font: quoteMarkFont,
                .foregroundColor: UIColor(red: 0.996, green: 0.918, blue: 0.910, alpha: 0.4) // #FEEAE8 with opacity
            ]
            let quoteMarkString = "\u{201C}" as NSString // Left double quotation mark
            let quoteMarkSize = quoteMarkString.size(withAttributes: quoteMarkAttrs)
            quoteMarkString.draw(
                at: CGPoint(x: padding, y: 300),
                withAttributes: quoteMarkAttrs
            )
            
            // Quote text
            let quoteFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
                .withSymbolicTraits(.traitItalic) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1),
                size: 48)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 12
            
            let quoteAttrs: [NSAttributedString.Key: Any] = [
                .font: quoteFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let quoteString = quote as NSString
            let quoteRect = CGRect(
                x: padding,
                y: 500,
                width: contentWidth,
                height: 1000
            )
            quoteString.draw(in: quoteRect, withAttributes: quoteAttrs)
            
            // Calculate where quote text ends
            let quoteSize = quoteString.boundingRect(
                with: CGSize(width: contentWidth, height: 1000),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: quoteAttrs,
                context: nil
            )
            
            // Source/attribution
            let sourceFont = UIFont.systemFont(ofSize: 32, weight: .medium)
            let sourceParagraphStyle = NSMutableParagraphStyle()
            sourceParagraphStyle.alignment = .center
            
            let sourceAttrs: [NSAttributedString.Key: Any] = [
                .font: sourceFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .paragraphStyle: sourceParagraphStyle
            ]
            
            let sourceString = "— \(source)" as NSString
            let sourceY = 500 + quoteSize.height + 40
            let sourceRect = CGRect(
                x: padding,
                y: sourceY,
                width: contentWidth,
                height: 100
            )
            sourceString.draw(in: sourceRect, withAttributes: sourceAttrs)
            
            // Add app branding at bottom
            let brandFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
            let brandParagraphStyle = NSMutableParagraphStyle()
            brandParagraphStyle.alignment = .center
            
            let brandAttrs: [NSAttributedString.Key: Any] = [
                .font: brandFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .paragraphStyle: brandParagraphStyle
            ]
            
            let brandString = "Littlebook" as NSString
            let brandRect = CGRect(
                x: padding,
                y: height - 150,
                width: contentWidth,
                height: 50
            )
            brandString.draw(in: brandRect, withAttributes: brandAttrs)
        }
    }
}
