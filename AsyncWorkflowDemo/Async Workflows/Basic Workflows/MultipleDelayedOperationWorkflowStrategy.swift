//
//  Created by Brian Coyner on 8/9/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class MultipleDelayedOperationWorkflowStrategy: WorkflowStrategy {

    func operations(withSession session: Session) -> [Operation] {
        return [
            DelayedIterationOperation(iterations: 5, iterationDelay: 2, session: session, pendingUnitCount: 30),
            DelayedIterationOperation(iterations: 1, iterationDelay: 3, session: session, pendingUnitCount: 50),
            DelayedIterationOperation(iterations: 10, iterationDelay: 1, session: session, pendingUnitCount: 20)
        ]
    }
}
