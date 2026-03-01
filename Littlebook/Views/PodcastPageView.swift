import SwiftUI

// MARK: - Top-level Router

struct PodcastPageView: View {
    let item: DailyContent
    @EnvironmentObject var player: PodcastPlayer

    var body: some View {
        if let podcast = item.podcast {
            PodcastPlayerView(item: item, podcast: podcast)
                // Auto-load when the user navigates to this date's episode.
                // Guard prevents reloading if the same episode is already loaded.
                .task(id: item.date) {
                    guard player.currentPodcast?.audioURL != podcast.audioURL else { return }
                    player.load(podcast: podcast, book: item.book)
                }
        } else {
            PodcastUnavailableView()
        }
    }
}

// MARK: - Player View

struct PodcastPlayerView: View {
    let item: DailyContent
    let podcast: Podcast

    @EnvironmentObject var player: PodcastPlayer
    @State private var isScriptExpanded = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                // Category badge
                Text("PODCAST")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(2)
                    .foregroundColor(.gray)
                    .padding(.top, 16)

                // Animated waveform visualization
                waveformView
                    .frame(height: 80)
                    .padding(.horizontal, 8)

                // One-sentence teaser
                Text(podcast.teaser)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(.primary.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Progress bar + time labels + transport controls
                VStack(spacing: 12) {
                    progressBar
                    timeLabels
                    transportControls
                }
                .padding(.horizontal, 8)

                // Expandable episode script
                scriptSection

                // Share episode button
                ShareLink(
                    item: "I just listened to an AI podcast about \"\(item.book.title)\" on Littlebook. \(podcast.teaser)",
                    subject: Text("Littlebook Podcast")
                ) {
                    Label("Share Episode", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(22)
                }

                // Error message (if any)
                if case .error(let msg) = player.state {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Waveform

    /// Fixed relative bar heights — defines the "fingerprint" shape of the waveform.
    private static let barHeights: [CGFloat] = [
        0.30, 0.50, 0.70, 0.60, 0.90, 0.80, 0.50, 0.40, 0.80, 0.90,
        0.60, 0.70, 0.40, 0.80, 0.50, 0.60, 0.90, 0.70, 0.50, 0.80,
        0.60, 0.40, 0.70, 0.90, 0.50, 0.60, 0.80, 0.40, 0.70, 0.50
    ]

    @ViewBuilder
    private var waveformView: some View {
        if player.state == .playing {
            // TimelineView drives a continuously-updated phase value for the animation.
            TimelineView(.animation) { ctx in
                waveformBars(phase: ctx.date.timeIntervalSinceReferenceDate)
            }
        } else {
            waveformBars(phase: 0)
        }
    }

    private func waveformBars(phase: Double) -> some View {
        let isPlaying = player.state == .playing
        return GeometryReader { geo in
            let count = Self.barHeights.count
            let spacing: CGFloat = 3
            let barWidth = (geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count)

            HStack(alignment: .center, spacing: spacing) {
                ForEach(Self.barHeights.indices, id: \.self) { i in
                    let base = Self.barHeights[i]
                    let scale: CGFloat = isPlaying
                        ? base * CGFloat(abs(sin(phase * 3.5 + Double(i) * 0.35))) * 0.7 + base * 0.3
                        : base * 0.35

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "#F8705E"))
                        .opacity(isPlaying ? 0.9 : 0.35)
                        .frame(width: barWidth, height: max(4, geo.size.height * scale))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        Slider(
            value: Binding(
                get: { player.duration > 0 ? player.currentTime / player.duration : 0 },
                set: { player.seek(to: $0 * player.duration) }
            ),
            in: 0...1
        )
        .tint(Color(hex: "#F8705E"))
        .disabled(!player.state.isActive)
    }

    private var timeLabels: some View {
        HStack {
            Text(formatTime(player.currentTime))
            Spacer()
            Text(formatTime(player.duration))
        }
        .font(.caption.monospacedDigit())
        .foregroundColor(.secondary)
    }

    // MARK: - Transport Controls

    private var transportControls: some View {
        HStack(spacing: 44) {
            // Skip back 15 s
            Button { player.skip(by: -15) } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 26))
                    .foregroundColor(.secondary)
            }
            .disabled(!player.state.isActive)

            // Play / Pause (or loading spinner)
            ZStack {
                if player.isBuffering || player.state == .loading {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(Color(hex: "#F8705E"))
                } else {
                    Button {
                        if player.state == .idle {
                            player.load(podcast: podcast, book: item.book)
                        } else {
                            player.togglePlayPause()
                        }
                    } label: {
                        Image(systemName: player.state == .playing ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color(hex: "#F8705E"))
                    }
                }
            }
            .frame(width: 64, height: 64)

            // Skip forward 15 s
            Button { player.skip(by: 15) } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 26))
                    .foregroundColor(.secondary)
            }
            .disabled(!player.state.isActive)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Script Accordion

    private var scriptSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isScriptExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Episode Script", systemImage: "text.alignleft")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isScriptExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            // Expandable body
            if isScriptExpanded {
                Text(podcast.script)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .padding(16)
                    .background(
                        Color.primary.opacity(0.04),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .clipped()
    }

    // MARK: - Helpers

    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Unavailable State

struct PodcastUnavailableView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "waveform.slash")
                .font(.system(size: 54))
                .foregroundColor(.secondary.opacity(0.45))
            Text("No episode today")
                .font(.system(size: 22, weight: .semibold, design: .serif))
            Text("AI podcast episodes are available for new daily books. Check back tomorrow.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}
