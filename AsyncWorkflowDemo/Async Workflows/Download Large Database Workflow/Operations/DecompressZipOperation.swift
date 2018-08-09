//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class DecompressZipFileOperation: WorkflowOperation {

    override func doMain(with session: Session) {
        let compressedFileURL: URL = session.published(valueForKey: String(describing: URL.self))
        print("Compressed File URL: \(compressedFileURL)")

        // STEP 1: Open the file
        // STEP 2: Decompress the file
        let contentSize = Int64(155_000_000)
        progress.totalUnitCount = contentSize

        let chunkSize = 2_000_000
        for iteration in stride(from: 0, to: contentSize, by: chunkSize) {
            if isCancelled {
                print("... cancelled")
                break
            }

            print("... Iteration \(iteration)")
            Thread.sleep(forTimeInterval: 0.1)
            let proposedCompletedUnitCount = progress.completedUnitCount + Int64(chunkSize)
            progress.completedUnitCount = min(contentSize, proposedCompletedUnitCount)
        }

        // STEP 3: If not canceled, publish the decompressed file URL (typically stored in the temp directory)

        guard !isCancelled else {
            return
        }

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("foo.sqlite"))
        session.publish(fileURL, forKey: String(describing: URL.self))
    }
}
