//
//  Created by Brian Coyner on 8/9/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class MultipleOperationsWorkflowStrategy: WorkflowStrategy {

    func operations(withSession session: Session) -> [Operation] {
        return dependentOperations(with: [
            DelayedIterationOperation(iterations: 1, iterationDelay: 1, session: session, pendingUnitCount: 25),
            DelayedIterationOperation(iterations: 1, iterationDelay: 1, session: session, pendingUnitCount: 25),
            DelayedIterationOperation(iterations: 1, iterationDelay: 1, session: session, pendingUnitCount: 25),
            DelayedIterationOperation(iterations: 1, iterationDelay: 1, session: session, pendingUnitCount: 25)
        ])
    }
}
