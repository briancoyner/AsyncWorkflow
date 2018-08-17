//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class MoveFileOperation: WorkflowOperation {

    fileprivate let destinationFileURL: URL

    init(destinationFileURL: URL, session: Session, pendingUnitCount: Int64 = 1) {
        self.destinationFileURL = destinationFileURL

        super.init(session: session, pendingUnitCount: pendingUnitCount)
    }

    override func doMain(with session: Session) {

        let sourceFileURL: URL = session.published(valueForKey: String(describing: URL.self))
        print("Source File URL: \(sourceFileURL)")

        // STEP 1: Move the file
        // STEP 2: Publish the destination file URL
        session.publish(destinationFileURL, forKey: String(describing: URL.self))
    }
}
