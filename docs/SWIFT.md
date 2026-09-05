# For Apple (iPhone, iPad, and Mac)

One SwiftUI project. The download is the full Xcode project so you can build and run it yourself.

## Requirements

- macOS with [Xcode](https://developer.apple.com/xcode/) 15 or later
- iOS 17 or macOS 14

## Open the project

1. Download `TierList-For-Apple-1.0.0.zip` from the website, or use the `TierListApp/` folder in this repo.
2. Open `TierListApp.xcodeproj`.
3. Select **iPhone**, **iPad**, or **My Mac**, then press Run.

On a physical iPhone or iPad, set your **Development Team** under Signing & Capabilities.

## Use the app

1. Add images from your photo library.
2. Press and hold an image, then drag it onto S, A, B, C, D, or F. It locks into that row.
3. On iPhone, the board uses compact rows so it stays usable in one hand. Scroll if you need more room.
4. Drag between rows to re-rank. Use the context menu to send an image back to the tray.
5. The ⋯ menu can reset ranks or clear everything.

## Project files

| File | Role |
| --- | --- |
| `TierListApp.swift` | App entry (iOS and Mac window) |
| `ContentView.swift` | Layout, picker, toolbar |
| `TierBoard.swift` | Ranking state |
| `TierRowView.swift` / `UnrankedTrayView.swift` | Drop targets |
| `ImageTileView.swift` | Image tiles |
