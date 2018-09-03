//
//  Created by Brian Coyner on 8/9/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

struct AsyncDemoMenuBuilder: MenuBuilder {

    let title = "Async Workflows"

    func makeMenu() -> [Menu] {
        return [
            Menu(title: "Progress Examples", items: [
                MenuItem(title: "Simple Operation Workflow", viewControllerProvider: {
                    return DemoWorkflowViewController(workflowStrategy: MultipleOperationsWorkflowStrategy())
                }),
                MenuItem(title: "Single Operation Workflow", viewControllerProvider: {
                    return DemoWorkflowViewController(workflowStrategy: SingleOperationWorkflowStrategy())
                }),
                MenuItem(title: "Multiple Dependent Operations Workflow", viewControllerProvider: {
                    return DemoWorkflowViewController(workflowStrategy: MultipleDependentDelayedOperationWorkflowStrategy())
                }),
                MenuItem(title: "Multiple Operations Workflow", viewControllerProvider: {
                    return DemoWorkflowViewController(workflowStrategy: MultipleDelayedOperationWorkflowStrategy())
                })
            ]),
            Menu(title: "Download Examples", items: [
                MenuItem(title: "Download SQLite File", viewControllerProvider: {
                    return DemoWorkflowViewController(workflowStrategy: DownloadSQLiteDatabaseWorkflowStrategy(
                        destinationFileURL: URL(fileURLWithPath: NSTemporaryDirectory()))
                    )
                }),
                MenuItem(title: "Download SQLite File (Cancel With Error)", viewControllerProvider: {
                    return DemoWorkflowViewController(workflowStrategy: DownloadSQLiteDatabaseWorkflowStrategy(
                        shouldForceError: true,
                        destinationFileURL: URL(fileURLWithPath: NSTemporaryDirectory()))
                    )
                })
            ])
        ]
    }
}
