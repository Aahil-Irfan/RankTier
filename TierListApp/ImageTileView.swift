import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ImageTileView: View {
    let item: RankedItem
    var size: CGFloat = 80

    var body: some View {
        Group {
            if let image = platformImage {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.white.opacity(0.7))
                    }
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .clipped()
    }

    #if canImport(UIKit)
    private var platformImage: UIImage? {
        UIImage(data: item.imageData)
    }
    #elseif canImport(AppKit)
    private var platformImage: NSImage? {
        NSImage(data: item.imageData)
    }
    #endif
}

#if canImport(UIKit)
private extension Image {
    init(platformImage: UIImage) {
        self.init(uiImage: platformImage)
    }
}
#elseif canImport(AppKit)
private extension Image {
    init(platformImage: NSImage) {
        self.init(nsImage: platformImage)
    }
}
#endif
