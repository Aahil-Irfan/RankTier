import SwiftUI

struct UnrankedTrayView: View {
    let items: [RankedItem]
    var onDrop: (UUID, Int) -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var isTargeted = false

    private var tileSize: CGFloat { sizeClass == .compact ? 64 : 80 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(items.isEmpty ? "Add images, then drag them into a tier" : "Hold and drag an image into a tier to lock it in")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if items.isEmpty {
                        placeholder
                    } else {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            ImageTileView(item: item, size: tileSize)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .draggable(DragItemID(id: item.id)) {
                                    ImageTileView(item: item, size: tileSize)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                                .dropDestination(for: DragItemID.self) { payloads, _ in
                                    guard let id = payloads.first?.id else { return false }
                                    onDrop(id, index)
                                    return true
                                }
                        }
                    }
                }
                .padding(8)
                .frame(minWidth: 120, minHeight: tileSize + 16, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.16, green: 0.16, blue: 0.17))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isTargeted ? Color.white.opacity(0.7) : Color.white.opacity(0.12), lineWidth: isTargeted ? 2 : 1)
            }
            .dropDestination(for: DragItemID.self) { payloads, location in
                guard let id = payloads.first?.id else { return false }
                let index = min(max(Int(location.x / (tileSize + 8)), 0), items.count)
                onDrop(id, index)
                return true
            } isTargeted: { hovering in
                isTargeted = hovering
            }
        }
    }

    private var placeholder: some View {
        HStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle.angled")
            Text("No images yet")
        }
        .font(.subheadline)
        .foregroundStyle(.white.opacity(0.45))
        .frame(height: tileSize)
        .padding(.horizontal, 8)
    }
}
