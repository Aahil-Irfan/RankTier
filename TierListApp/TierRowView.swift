import SwiftUI

struct TierRowView: View {
    let tier: Tier
    let items: [RankedItem]
    var onDrop: (UUID, Int) -> Void
    var onReturnToTray: (UUID) -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var isTargeted = false

    private var isCompact: Bool { sizeClass == .compact }
    private var labelWidth: CGFloat { isCompact ? 48 : 88 }
    private var rowHeight: CGFloat { isCompact ? 64 : 88 }
    private var labelSize: CGFloat { isCompact ? 26 : 42 }

    var body: some View {
        HStack(spacing: 0) {
            Text(tier.label)
                .font(.system(size: labelSize, weight: .heavy, design: .rounded))
                .foregroundStyle(.black)
                .frame(width: labelWidth, height: rowHeight)
                .background(tier.color)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        ImageTileView(item: item, size: rowHeight)
                            .draggable(DragItemID(id: item.id)) {
                                ImageTileView(item: item, size: rowHeight)
                                    .opacity(0.9)
                            }
                            .contextMenu {
                                Button("Move to tray") {
                                    onReturnToTray(item.id)
                                }
                            }
                            .dropDestination(for: DragItemID.self) { payloads, _ in
                                guard let id = payloads.first?.id else { return false }
                                onDrop(id, index)
                                return true
                            }
                    }
                }
                .frame(minHeight: rowHeight)
            }
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
            .background(Color(red: 0.16, green: 0.16, blue: 0.17))
            .overlay {
                if isTargeted {
                    Rectangle()
                        .stroke(tier.color, lineWidth: 3)
                }
            }
            .dropDestination(for: DragItemID.self) { payloads, location in
                guard let id = payloads.first?.id else { return false }
                let index = insertionIndex(at: location, count: items.count)
                onDrop(id, index)
                return true
            } isTargeted: { hovering in
                isTargeted = hovering
            }
        }
        .frame(height: rowHeight)
    }

    private func insertionIndex(at location: CGPoint, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let raw = Int(location.x / rowHeight)
        return min(max(raw, 0), count)
    }
}
