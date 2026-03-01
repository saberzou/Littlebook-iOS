# Littlebook iOS

Native iOS app for [Littlebook](https://saberzou.github.io/Littlebook/) — a daily book, wallpaper & quote experience.

## Architecture

- **SwiftUI** — iOS 16+
- **Data** — fetched from GitHub (`daily-data.json`), bundled copy as fallback
- **Wallpapers** — Unsplash (hardcoded photo IDs, stable per date)
- **Book covers** — Open Library API

## Structure

```
Littlebook/
  LittlebookApp.swift       — App entry point
  Models/DailyContent.swift — Data models
  Services/ContentStore.swift — Data loading & state
  Views/DailyView.swift     — Main daily card view
  Assets.xcassets/          — App icon & assets
daily-data.json             — Content data (synced from web repo)
```

## Setup & Build in Xcode

1. **Open the project**  
   Double-click `Littlebook.xcodeproj` in the project root, or in Xcode: **File → Open** and select the `Littlebook-iOS` folder (or the `.xcodeproj` file).

2. **Select a run destination**  
   In the Xcode toolbar, choose a simulator (e.g. **iPhone 17**) or a connected device from the scheme/destination menu.

3. **Build and run**  
   Press **⌘R** (or click the Run button) to build and launch the app.

4. **From the command line** (optional):
   ```bash
   xcodebuild -scheme Littlebook -destination 'platform=iOS Simulator,name=iPhone 17' build
   ```

**Requirements:** Xcode 15+, iOS 17+ deployment target.  
To bundle `daily-data.json` in the app (e.g. for the daily-content flow), drag it into the **Littlebook** group in Xcode and check **Copy items if needed**.

## Content Updates

Content is fetched from this repo's `daily-data.json` at launch. To add new days, update the JSON and push — no app update needed.

## TODO

- [ ] Wallpaper download & save to Photos
- [ ] Share quote as image
- [ ] Widget (daily quote on home screen)
- [ ] Push notification for daily content
- [ ] Offline caching
- [ ] App icon design
