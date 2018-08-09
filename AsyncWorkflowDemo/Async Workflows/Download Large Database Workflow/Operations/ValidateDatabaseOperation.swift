//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class ValidateDatabaseOperation: WorkflowOperation {

    override func doMain(with session: Session) {
        let databaseFileURL: URL = session.published(valueForKey: String(describing: URL.self))
        print("Database File URL: \(databaseFileURL)")

        // STEP 1: Attempt to open the database
        Thread.sleep(forTimeInterval: 0.25)

        // STEP 2: Validate the database
        Thread.sleep(forTimeInterval: 2)

        // STEP 3: Attempt to close the database
        Thread.sleep(forTimeInterval: 0.25)
    }
}
