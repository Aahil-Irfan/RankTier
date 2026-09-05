import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var board = TierBoard()
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isCompact: Bool { sizeClass == .compact }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 1) {
                        ForEach(Tier.allCases) { tier in
                            TierRowView(
                                tier: tier,
                                items: board.items(at: .tier(tier)),
                                onDrop: { id, index in
                                    withAnimation(.snappy) {
                                        board.move(id, to: .tier(tier), at: index)
                                    }
                                },
                                onReturnToTray: { id in
                                    withAnimation(.snappy) {
                                        board.returnToTray(id)
                                    }
                                }
                            )
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .padding(.horizontal, isCompact ? 8 : 12)
                    .padding(.top, isCompact ? 8 : 12)

                    UnrankedTrayView(items: board.items(at: .unranked)) { id, index in
                        withAnimation(.snappy) {
                            board.move(id, to: .unranked, at: index)
                        }
                    }
                    .padding(isCompact ? 8 : 12)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Tier List")
            .toolbar { toolbarContent }
            .overlay {
                if isImporting {
                    ProgressView("Adding images…")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
        }
        .preferredColorScheme(.dark)
        .onChange(of: pickerItems) { _, newItems in
            Task { await importPickedImages(newItems) }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Menu {
                Button("Reset ranks") {
                    withAnimation { board.resetRanks() }
                }
                Button("Clear all", role: .destructive) {
                    withAnimation { board.clearAll() }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel("More")
        }
        ToolbarItem(placement: .primaryAction) {
            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 50,
                matching: .images
            ) {
                if isCompact {
                    Image(systemName: "photo.badge.plus")
                } else {
                    Label("Add Images", systemImage: "photo.badge.plus")
                }
            }
            .accessibilityLabel("Add Images")
        }
    }

    @MainActor
    private func importPickedImages(_ newItems: [PhotosPickerItem]) async {
        guard !newItems.isEmpty else { return }
        isImporting = true
        defer {
            isImporting = false
            pickerItems = []
        }

        for item in newItems {
            if let imported = try? await item.loadTransferable(type: ImportedImageData.self),
               !imported.data.isEmpty {
                board.addImage(data: imported.data)
            } else if let data = try? await item.loadTransferable(type: Data.self),
                      !data.isEmpty {
                board.addImage(data: data)
            }
        }
    }
}

#Preview {
    ContentView()
}
