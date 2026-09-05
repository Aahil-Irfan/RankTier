import SwiftUI

@main
struct TierListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .defaultSize(width: 960, height: 720)
        #endif
    }
}
