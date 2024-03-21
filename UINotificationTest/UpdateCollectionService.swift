import Foundation
import Combine

class UpdateCollectionService
{
    var items = [Item]()
    init()
    {
        
    }
    static var publisher: AsyncPublisher<AnyPublisher<(Item, Item.UpdateType), Never>> {
        AsyncPublisher(subject.eraseToAnyPublisher())
    }

    /// sent self.id, and the new selectedAttachmentId
    private static let subject = PassthroughSubject<(Item, Item.UpdateType), Never>()
    
    private func updateView(withUpdateTo updateType: Item.UpdateType, item: Item) {
        UpdateCollectionService.subject.send((item, updateType))
    }
    
    @objc
    @MainActor
    public func addItem()
    {
        print("addItem \(items.count)")
        let item = Item(name: "newItem \(items.count)")
        items.append(item)
        updateView(withUpdateTo: .newItem, item: item)
    }
    
    @objc
    @MainActor
    public func updateCountForLastItem()
    {
        print("updateCountForLastItem")
        if let item = items.last
        {
            item.count = item.count + 1
            updateView(withUpdateTo: .changeNumber, item: item)
        }
    }
    @objc
    @MainActor
    public func updateConuntEveryItem()
    {
        print("updateCountForEveryItem")
        for item in items
        {
            print("updating item \(item.name)")
            item.count = item.count + 1
            updateView(withUpdateTo: .changeNumber, item: item)
        }
    }
}

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
