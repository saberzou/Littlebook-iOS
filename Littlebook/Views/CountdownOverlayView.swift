import SwiftUI

struct CountdownOverlayView: View {
    let targetDate: String

    private var midnight: Date {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: targetDate) else { return Date() }
        return Calendar.current.startOfDay(for: date)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "hourglass")
                    .font(.system(size: 56))
                    .foregroundColor(.orange)
                    .symbolEffect(.pulse)

                Text("Tomorrow's content unlocks in")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                TimelineView(.periodic(from: Date(), by: 1)) { _ in
                    Text(countdownText())
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(40)
        }
    }

    private func countdownText() -> String {
        let remaining = midnight.timeIntervalSinceNow
        guard remaining > 0 else { return "00:00:00" }
        let h = Int(remaining) / 3600
        let m = (Int(remaining) % 3600) / 60
        let s = Int(remaining) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
