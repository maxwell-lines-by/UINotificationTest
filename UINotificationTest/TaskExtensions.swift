//
//  TaskExtensions.swift
//  typo_mobile
//
//  Created by Eli Burnes on 3/1/24.

import Combine
import Foundation

// Copied from: https://www.hackingwithswift.com/quick-start/concurrency/how-to-make-a-task-sleep
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

// A class wrapper for the Task which type is erased and being cancelled when it's released.
// Useful to replace `Set<AnyCancellable>` with `async` code.
final class AnyTaskCancellable: Hashable {
    // Pointer comparison should be enough. This is a wrapper.
    static func == (lhs: AnyTaskCancellable, rhs: AnyTaskCancellable) -> Bool {
        lhs === rhs
    }

    private let hashIntoBlock: (inout Hasher) -> Void
    private let cancelBlock: () -> Void
    private let isCancelledBlock: () -> Bool

    init(_ task: Task<some Sendable, some Error>) {
        // Erase type by closures for each method.
        hashIntoBlock = { hasher in
            task.hash(into: &hasher)
        }
        cancelBlock = {
            task.cancel()
        }
        isCancelledBlock = {
            task.isCancelled
        }
    }

    deinit {
        cancel()
    }

    func hash(into hasher: inout Hasher) {
        hashIntoBlock(&hasher)
    }

    var isCancelled: Bool {
        isCancelledBlock()
    }

    func cancel() {
        cancelBlock()
    }
}

// Compatibility with Combine `Cancellable`.
extension AnyTaskCancellable: Cancellable {}

extension Task {
    func toAnyTaskCancellable() -> AnyTaskCancellable {
        AnyTaskCancellable(self)
    }

    func store(in set: inout Set<AnyTaskCancellable>) {
        set.insert(toAnyTaskCancellable())
    }
}
