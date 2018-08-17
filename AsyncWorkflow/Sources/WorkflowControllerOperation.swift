//
//  Created by Brian Coyner on 10/31/15.
//  Copyright © 2015 Brian Coyner. All rights reserved.
//

import Foundation
import UIKit

/// An operation that helps developers build, execute and monitor an async workflow.
///
/// The workflow operations provided by the `WorkflowStrategy` execute on a
/// private concurrent queue.

public final class WorkflowControllerOperation: Operation, ProgressReporting {

    public let session: Session
    public let progress: Progress

    fileprivate let strategy: WorkflowStrategy
    fileprivate var sessionErrorObserver: NSKeyValueObservation?
    fileprivate let operationQueue: OperationQueue
    fileprivate var backgroundTaskIdentifier: UIBackgroundTaskIdentifier

    public init(strategy: WorkflowStrategy, session: Session = Session()) {
        self.strategy = strategy
        self.session = session
        self.operationQueue = OperationQueue()
        self.backgroundTaskIdentifier = .invalid
        self.progress = Progress()

        super.init()
    }
}

extension WorkflowControllerOperation {

    public override func main() {
        if strategy.allowedToExecuteInBackground() {
            backgroundTaskIdentifier = beginBackgroundTaskWithWorkflowName(session.name)
        }

        sessionErrorObserver = session.observe(\Session.error, changeHandler: handleSessionError)

        let operations = strategy.operations(withSession: session)

        configure(progress, for: operations)

        print("The '\(String(describing: (type(of: self))))' operation will submit operations: \(operations).")
        operationQueue.addOperations(operations, waitUntilFinished: true)
        print("The '\(String(describing: (type(of: self))))' operation did complete.")

        if backgroundTaskIdentifier != .invalid {
            endBackgroundTaskWithIdentifier(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
        }

        sessionErrorObserver = nil
    }
}

extension WorkflowControllerOperation {

    public override func cancel() {
        print("The workflow controller operation was cancelled. Calling thread '\(Thread.current.name ?? "Unknown Thread")'.")

        super.cancel()
        cancelAllOperations()
    }

    private func cancelAllOperations() {
        print("The '(\(String(describing: (type(of: self))))' operation will cancel all operations.")
        operationQueue.isSuspended = true
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = false
        print("The '(\(String(describing: type(of: self))))' operation did cancel all operations.")
    }
}

extension WorkflowControllerOperation {

    fileprivate func handleSessionError(session: Session, change: NSKeyValueObservedChange<Error?>) {
        print("The '(\(String(describing: (type(of: self))))' operation will cancel with error.")
        cancel()
    }
}

extension WorkflowControllerOperation {

    fileprivate func beginBackgroundTaskWithWorkflowName(_ name: String) -> UIBackgroundTaskIdentifier {
        let application = UIApplication.shared
        let backgroundTaskIdentifier = application.beginBackgroundTask {
            print("Operation '\(String(describing: type(of: self)))' named '\(name), executing while the app is in the background, will be cancelled. Time remaining: \(application.backgroundTimeRemaining)")
            self.cancel()
        }

        return backgroundTaskIdentifier
    }

    fileprivate func endBackgroundTaskWithIdentifier(_ identifier: UIBackgroundTaskIdentifier) {
        let application = UIApplication.shared
        application.endBackgroundTask(identifier)
    }
}

extension WorkflowControllerOperation {

    fileprivate func configure(_ progress: Progress, for operations: [Operation]) {

        var totalUnitCount = progress.totalUnitCount

        for operation in operations {
            guard let workflowOperation = operation as? WorkflowOperation else {
                continue
            }

            totalUnitCount += workflowOperation.pendingUnitCount
            progress.addChild(workflowOperation.progress, withPendingUnitCount: workflowOperation.pendingUnitCount)
        }

        progress.totalUnitCount = totalUnitCount
    }
}

// MARK: Dependent Operation Set Up

/// The given array of operations is made dependent on each other.
///
/// For example, an array containing the [A, B, C, D]
/// - B depends on A
/// - C depends on B
/// - D depends on C
public func dependentOperations(with operations: [Operation]) -> [Operation] {

    var currentOperation: Operation?
    for dependentOperation in operations {
        if currentOperation == nil {
            currentOperation = dependentOperation
        } else {
            dependentOperation.addDependency(currentOperation!)
            currentOperation = dependentOperation
        }
    }

    return operations
}
