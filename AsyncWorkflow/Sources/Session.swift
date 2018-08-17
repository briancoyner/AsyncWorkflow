//
//  Created by Brian M Coyner on 12/13/14.
//  Copyright (c) 2014 Brian Coyner. All rights reserved.
//

import Foundation

/// A workflow `Session` provides thread-safe access to a key/value store.
/// Multiple queues can read values from the session at a time, but only one queue
/// can write to the session at a time. This is accomplished using a privately
/// owned `DispatchQueue`.
///
/// A session instance is typically used across multiple instances of operations
/// working towards a common goal. More complicated workflows may choose to create
/// "isolated sessions" that eventually come together at the end of a workflow.

public final class Session: NSObject {

    public let name: String

    /// The `WorkflowControllerOperation` uses KVO to monitor for errors.
    /// Setting an error cancels the entire workflow.
    @objc dynamic public var error: Error?

    fileprivate let sessionInfo = NSMutableDictionary()
    fileprivate let isolationQueue: DispatchQueue

    public init(name: String = "Default") {
        self.name = name
        self.isolationQueue = DispatchQueue(
            label: "com.highrailcompany.workflowsession.isolationqueue",
            attributes: .concurrent
        )
    }
}

extension Session {

    public func published<T>(valueForKey key: String) -> T {
        guard let value: T = _value(forKey: key) else {
            fatalError("Unknown key in dictionary. Key: \(key). Values: \(sessionInfo)")
        }
        return value
    }

    public func publish(_ value: Any, forKey key: String) {
        // NOTE: We need to dispatch_async to prevent possible deadlocks. It is fine to return from this method
        //       before the write completes because any read from another thread will block until the barrier exits.
        isolationQueue.sync(flags: .barrier, execute: {
            self.sessionInfo[key] = value
        })
    }

    public func optionalPublishedObjectForKey<T>(_ key: String) -> T? {
        return _value(forKey: key)
    }
}

extension Session {

    public func copyOfSessionInfo() -> [String: Any] {
        var copy: [String: Any] = [:]
        isolationQueue.sync(execute: {
            copy = sessionInfo.copy() as? [String: Any] ?? [:]
        })
        return copy
    }
}

extension Session {

    fileprivate func _value<T>(forKey key: String) -> T? {
        var object: T?
        isolationQueue.sync(execute: {
            object = self.sessionInfo[key] as? T
        })
        return object
    }
}
