//
//  Created by Brian Coyner on 8/8/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()
}

extension AppDelegate {

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        //
        // This app is displays a simple "menu" of options that execute different types of
        // async workflows.
        //
        // See the `AsyncDemoMenuBuilder` for additional details.
        //

        let menuViewController = MenuViewController(title: "Async Demos", menus: AsyncDemoMenuBuilder.makeMenu())
        let navigationController = UINavigationController(rootViewController: menuViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
