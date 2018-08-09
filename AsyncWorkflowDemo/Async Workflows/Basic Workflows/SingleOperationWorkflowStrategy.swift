//
//  Created by Brian Coyner on 8/9/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class SingleOperationWorkflowStrategy: WorkflowStrategy {

    func operations(withSession session: Session) -> [Operation] {
        return dependentOperations(with: [
            DelayedIterationOperation(iterations: 5, iterationDelay: 1, session: session, pendingUnitCount: 25),
            DelayedIterationOperation(iterations: 5, iterationDelay: 0.5, session: session, pendingUnitCount: 75)
        ])
    }
}