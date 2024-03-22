import Foundation
import Combine

class DebouncedPublisher<T> {
    private let updateQueue = OperationQueue()
    private var pendingUpdates = [T]()
    private var debounceTimer: Timer?
    var subject = PassthroughSubject<T, Never>()
    
    init() {
        updateQueue.maxConcurrentOperationCount = 1 // Serial execution
    }
    
    private func debounceAndProcessUpdates() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { [weak self] _ in
            self?.processUpdates()
        }
    }
    
    private func processUpdates() {
        let update = pendingUpdates.removeFirst()
        subject.send(update)
        
        if !pendingUpdates.isEmpty
        {
            debounceAndProcessUpdates()
        }
    }
    
    public func publish(update: T)
    {
        pendingUpdates.append(update)
        debounceAndProcessUpdates()
    }
}
