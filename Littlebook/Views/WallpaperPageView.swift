import SwiftUI
import Photos

struct WallpaperPageView: View {
    let item: DailyContent
    @State private var saveStatus: SaveStatus = .idle
    @State private var downloadedImage: UIImage?

    enum SaveStatus { case idle, saving, saved, failed }

    var body: some View {
        ZStack {
            if let wp = item.wallpaper, let url = wp.portraitURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                            .onAppear {
                                // Cache the UIImage for saving
                                Task {
                                    if let data = try? await URLSession.shared.data(from: url).0 {
                                        downloadedImage = UIImage(data: data)
                                    }
                                }
                            }
                    case .failure:
                        wallpaperPlaceholder
                    default:
                        wallpaperPlaceholder
                            .overlay(ProgressView().tint(.white))
                    }
                }
            } else {
                wallpaperPlaceholder
            }

            // Bottom gradient overlay
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
            }
            .ignoresSafeArea()

            // Controls
            VStack {
                Spacer()
                HStack {
                    if let wp = item.wallpaper {
                        attributionButton(wp)
                    }
                    Spacer()
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
            }
        }
        .overlay(toastOverlay)
    }

    private var wallpaperPlaceholder: some View {
        Rectangle()
            .fill(Color(white: 0.1))
            .ignoresSafeArea()
    }

    private func attributionButton(_ wp: Wallpaper) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let creditURL = wp.creditURL {
                Link(destination: creditURL) {
                    HStack(spacing: 4) {
                        Image(systemName: "camera")
                            .font(.caption2)
                        Text(wp.user)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            if let unsplashURL = wp.unsplashURL {
                Link("via Unsplash", destination: unsplashURL)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.leading, 4)
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task { await saveWallpaper() }
        } label: {
            HStack(spacing: 6) {
                if saveStatus == .saving {
                    ProgressView().scaleEffect(0.7).tint(.white)
                } else {
                    Image(systemName: saveStatus == .saved ? "checkmark" : "arrow.down.to.line")
                }
                Text(saveStatus == .saved ? "Saved" : "Save")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(22)
        }
        .disabled(saveStatus == .saving || saveStatus == .saved)
    }

    @ViewBuilder
    private var toastOverlay: some View {
        if saveStatus == .failed {
            VStack {
                Spacer()
                Text("Could not save wallpaper. Check Photos permission.")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(10)
                    .padding(.bottom, 120)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func saveWallpaper() async {
        saveStatus = .saving
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            saveStatus = .failed
            return
        }

        let image: UIImage?
        if let cached = downloadedImage {
            image = cached
        } else if let wp = item.wallpaper, let url = wp.portraitURL,
                  let data = try? await URLSession.shared.data(from: url).0 {
            image = UIImage(data: data)
        } else {
            image = nil
        }

        guard let img = image else {
            saveStatus = .failed
            return
        }

        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            }) { success, _ in
                DispatchQueue.main.async {
                    saveStatus = success ? .saved : .failed
                    if success {
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            saveStatus = .idle
                        }
                    }
                }
                continuation.resume()
            }
        }
    }
}
