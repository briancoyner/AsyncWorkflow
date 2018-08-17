//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class DownloadSQLiteDatabaseWorkflowStrategy: WorkflowStrategy {

    fileprivate let shouldForceError: Bool
    fileprivate let destinationFileURL: URL

    init(shouldForceError: Bool = false, destinationFileURL: URL) {
        self.shouldForceError = shouldForceError
        self.destinationFileURL = destinationFileURL
    }

    func allowedToExecuteInBackground() -> Bool {
        return true
    }
}

extension DownloadSQLiteDatabaseWorkflowStrategy {

    func operations(withSession session: Session) -> [Operation] {

        let fakeDownloadError: DownloadOperation.DownloadError? = shouldForceError ? .fake : nil

        //
        // If you make the `pendingUnitCount` add up to 100 (i.e. 100%), then it makes it
        // really easy to see how progress is tracked across the top-level operations.
        //
        // In this case, the user sees
        // - between 0 and 1%, the `FetchFileMetaDataOperation` is executing
        // - between 1 and 49%, the `DownloadOperation` is executing
        // - between 49% and 100%, the 'DecompressZipFileOperation` and `MoveFileOperation` is executing
        //
        //
        // The `totalUnitCount` and `completedUnitCount` of each operation will automatically contribute
        // to the total progress managed by the `WorkflowControllerOperation`s "root" `Progress`. There
        // is a bit magic here. So you'll definitely want to read up on the `Progress` API.
        //

        return dependentOperations(with: [
            FetchFileMetaDataOperation(session: session, pendingUnitCount: 1),
            DownloadOperation(fakeError: fakeDownloadError, session: session, pendingUnitCount: 49),
            DecompressZipFileOperation(session: session, pendingUnitCount: 50),
            MoveFileOperation(destinationFileURL: destinationFileURL, session: session, pendingUnitCount: 0)
        ])
    }
}
