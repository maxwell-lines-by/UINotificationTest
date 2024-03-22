//
//  Item.swift
//  UINotificationTest
//
//  Created by Maxwell Altman on 3/21/24.
//

import Foundation
@MainActor
/// a generic item with a unique id, and a mutable name and count
class Item: Hashable, ObservableObject, Identifiable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    var name: String
    var count: Int
    init(name: String) {
        self.name = name
        id = UUID()
        count = 0
    }
    enum UpdateType: Sendable {
        case newItem
        case changeString
        case changeNumber
    }
}
