import SwiftUI
import UniformTypeIdentifiers
import CoreTransferable

enum Tier: String, CaseIterable, Identifiable, Codable {
    case s, a, b, c, d, f

    var id: String { rawValue }

    var label: String { rawValue.uppercased() }

    /// Colors matched to the classic tiermaker-style board.
    var color: Color {
        switch self {
        case .s: Color(red: 1.00, green: 0.31, blue: 0.31)
        case .a: Color(red: 1.00, green: 0.55, blue: 0.18)
        case .b: Color(red: 1.00, green: 0.80, blue: 0.20)
        case .c: Color(red: 0.55, green: 0.84, blue: 0.32)
        case .d: Color(red: 0.38, green: 0.73, blue: 0.95)
        case .f: Color(red: 0.73, green: 0.62, blue: 0.93)
        }
    }
}

struct RankedItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let imageData: Data
}

struct DragItemID: Codable, Transferable, Sendable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

struct ImportedImageData: Transferable, Sendable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            ImportedImageData(data: data)
        }
    }
}
