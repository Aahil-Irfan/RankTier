import Foundation
import Observation

enum ItemLocation: Hashable {
    case unranked
    case tier(Tier)
}

@Observable
final class TierBoard {
    private(set) var items: [UUID: RankedItem] = [:]
    private(set) var order: [ItemLocation: [UUID]] = {
        var map: [ItemLocation: [UUID]] = [.unranked: []]
        for tier in Tier.allCases {
            map[.tier(tier)] = []
        }
        return map
    }()

    func items(at location: ItemLocation) -> [RankedItem] {
        (order[location] ?? []).compactMap { items[$0] }
    }

    func addImage(data: Data) {
        let item = RankedItem(id: UUID(), imageData: data)
        items[item.id] = item
        order[.unranked, default: []].append(item.id)
    }

    func move(_ id: UUID, to destination: ItemLocation, at index: Int? = nil) {
        guard items[id] != nil else { return }

        for location in Array(order.keys) {
            order[location]?.removeAll { $0 == id }
        }

        var list = order[destination] ?? []
        let insertAt = min(max(index ?? list.count, 0), list.count)
        list.insert(id, at: insertAt)
        order[destination] = list
    }

    func returnToTray(_ id: UUID) {
        move(id, to: .unranked)
    }

    func resetRanks() {
        var pooled = order[.unranked] ?? []
        for tier in Tier.allCases {
            pooled.append(contentsOf: order[.tier(tier)] ?? [])
            order[.tier(tier)] = []
        }
        order[.unranked] = pooled
    }

    func clearAll() {
        items.removeAll()
        order[.unranked] = []
        for tier in Tier.allCases {
            order[.tier(tier)] = []
        }
    }
}
