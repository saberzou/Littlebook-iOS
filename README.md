# Littlebook iOS

Native iOS app for [Littlebook](https://saberzou.github.io/Littlebook/) — a daily book, wallpaper & quote experience.

## Architecture

- **SwiftUI** — iOS 16+
- **Data** — fetched from the deployed website feed first, then the web repo raw JSON, with the iOS repo JSON kept as a legacy fallback
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

The iOS app now treats the web experience as the source of truth:

- `https://saberzou.github.io/Littlebook/daily-data.json`
- `https://raw.githubusercontent.com/saberzou/Littlebook/main/daily-data.json`
- `https://raw.githubusercontent.com/saberzou/Littlebook-iOS/main/daily-data.json` as a legacy fallback

That means when the website's `daily-data.json` gets new book, quote, wallpaper, or podcast entries, the iOS app can pick them up without shipping a new app update.

## TODO

- [ ] Wallpaper download & save to Photos
- [ ] Share quote as image
- [ ] Widget (daily quote on home screen)
- [ ] Push notification for daily content
- [ ] Offline caching
- [ ] App icon design
