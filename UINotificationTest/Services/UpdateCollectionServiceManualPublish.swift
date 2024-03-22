import Foundation
import Combine

class UpdateCollectionServiceManualPublish
{
    var items = [Item]()

    static var publisher: AsyncPublisher<AnyPublisher<(Item, Item.UpdateType), Never>> {
        AsyncPublisher(subject.eraseToAnyPublisher())
    }

    /// sent self.id, and the new selectedAttachmentId
    private static let subject = PassthroughSubject<(Item, Item.UpdateType), Never>()
    
    private func updateView(withUpdateTo updateType: Item.UpdateType, item: Item) {
        UpdateCollectionServiceManualPublish.subject.send((item, updateType))
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
    public func updateCountEveryItem()
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
