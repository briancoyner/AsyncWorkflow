//
//  Created by Brian M Coyner on 12/14/14.
//  Copyright (c) 2014 Brian Coyner. All rights reserved.
//

import Foundation

/// This is the main "base" class for all Async Workflow operations.

open class WorkflowOperation: Operation, ProgressReporting {

    public let session: Session
    public let progress: Progress
    public let pendingUnitCount: Int64

    public init(session: Session, pendingUnitCount: Int64 = 1) {
        self.session = session
        self.pendingUnitCount = pendingUnitCount

        self.progress = Progress()
        self.progress.totalUnitCount = 1

        super.init()
    }
}

extension WorkflowOperation {

    override open func main() {
        print("Will start workflow operation: \(type(of: self)); Name: \(name ?? "No name")")
        doMain(with: session)

        if !isCancelled {
            progress.completedUnitCount = progress.totalUnitCount
        }

        print("Did finish workflow operation: \(type(of: self))")
    }

    @objc
    open func doMain(with session: Session) {
        // no-op
    }
}
