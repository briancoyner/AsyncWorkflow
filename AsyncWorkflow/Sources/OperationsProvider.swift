//
//  Created by Brian Coyner on 10/31/15.
//  Copyright © 2015 Brian Coyner. All rights reserved.
//

import Foundation

/// Implementations provide an array `Operation` subclasses to execute on an `OperationQueue`.
/// It's up to the implementation to set up dependencies, as necessary.
///
/// - SeeAlso: `WorkflowControllerOperation`
/// - SeeAlso: `WorkflowStrategy`

public protocol OperationsProvider {
    func operations(withSession session: Session) -> [Operation]
}
