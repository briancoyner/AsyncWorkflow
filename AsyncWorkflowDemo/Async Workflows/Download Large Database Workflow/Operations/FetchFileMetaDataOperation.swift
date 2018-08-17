//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

import AsyncWorkflow

final class FetchFileMetaDataOperation: WorkflowOperation {

    override func doMain(with session: Session) {

        // STEP: 1 fetch the latest file details
        Thread.sleep(forTimeInterval: 0.5)

        // STEP: 2 publish the results which are used to build a URL request.
        let fileMetaData = FileMetaData(group: "Group A", category: "Category A", revision: 56)
        session.publish(fileMetaData, forKey: String(describing: FileMetaData.self))
    }
}
