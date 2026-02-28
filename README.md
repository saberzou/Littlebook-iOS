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

## Setup

1. Open in Xcode (create project via File → New → Project → App, then replace files)
2. Or use `xcodegen` / `tuist` to generate `.xcodeproj` from these sources
3. Add `daily-data.json` to the bundle (drag into Xcode, check "Copy items")
4. Build & run on simulator or device

## Content Updates

Content is fetched from this repo's `daily-data.json` at launch. To add new days, update the JSON and push — no app update needed.

## TODO

- [ ] Wallpaper download & save to Photos
- [ ] Share quote as image
- [ ] Widget (daily quote on home screen)
- [ ] Push notification for daily content
- [ ] Offline caching
- [ ] App icon design
