//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class DownloadOperation: WorkflowOperation {

    enum DownloadError: Error {
        case fake
    }

    fileprivate let fakeError: DownloadError?

    init(fakeError: DownloadError? = nil, session: Session, pendingUnitCount: Int64) {
        self.fakeError = fakeError

        super.init(session: session, pendingUnitCount: pendingUnitCount)
    }
}

extension DownloadOperation {

    override func doMain(with session: Session) {
        let fileMetaData: FileMetaData = session.published(valueForKey: String(describing: FileMetaData.self))
        print("File Meta Data: \(fileMetaData)")

        // STEP 1: Build URL request to download the file from the remote server based on the given meta data
        // STEP 2: Submit the request to a URLSession and track progress

        let contentSize = Int64(56_000_000)
        progress.totalUnitCount = contentSize

        let chunkSize = 750_000
        for iteration in stride(from: 0, to: contentSize, by: chunkSize) {
            if isCancelled {
                print("... cancelled")
                break
            }

            // Hack to set an error on the session to mimic canceling the workflow
            // due to a network related error.
            if fakeError != nil && progress.fractionCompleted > 0.3 {
                session.error = fakeError!
            }

            print("... Iteration \(iteration)")

            Thread.sleep(forTimeInterval: 0.1)
            let proposedCompletedUnitCount = progress.completedUnitCount + Int64(chunkSize)
            progress.completedUnitCount = min(contentSize, proposedCompletedUnitCount)
        }

        // STEP 3: If not canceled, publish downloaded file URL (typically stored in the temp directory)

        guard !isCancelled else {
            return
        }

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("foo.zip"))
        session.publish(fileURL, forKey: String(describing: URL.self))
    }
}
