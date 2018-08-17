//
//  Created by Brian Coyner on 8/9/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

import AsyncWorkflow

/// This example workflow operation simply iterates a certain number of iterations (`iterations`)
/// and pauses between each iteration for a specified period of time (`iterationDelay`).
///
/// The operation checks for cancellation at each iteration.

final class DelayedIterationOperation: WorkflowOperation {

    let iterations: Int
    let iterationDelay: TimeInterval

    init(iterations: Int = 1, iterationDelay: TimeInterval = 1, session: Session, pendingUnitCount: Int64 = 1) {
        self.iterations = iterations
        self.iterationDelay = iterationDelay

        super.init(session: session, pendingUnitCount: pendingUnitCount)

        self.name = "\(type(of: self)); Iterations: \(iterations); Delay: \(iterationDelay)"
    }
}

extension DelayedIterationOperation {

    override func doMain(with session: Session) {

        progress.totalUnitCount = Int64(iterations)

        for iteration in 0..<iterations {
            if isCancelled {
                print("... '\(name!)'; cancelled")
                break
            }

            print("... Iteration \(iteration); '\(name!)'; Thread '\(Thread.current)'")
            Thread.sleep(forTimeInterval: iterationDelay)
            progress.completedUnitCount = Int64(iteration + 1)
        }
    }
}
