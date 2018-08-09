//
//  Created by Brian Coyner on 10/31/15.
//  Copyright © 2015 High Rail, LLC. All rights reserved.
//

import Foundation

public protocol WorkflowStrategy: OperationsProvider {

    func allowedToExecuteInBackground() -> Bool
}

public extension WorkflowStrategy {

    func allowedToExecuteInBackground() -> Bool {
        return false
    }
}
