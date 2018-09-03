//
//  Created by Brian Coyner on 9/3/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation

struct MainMenuBuilder: MenuBuilder {

    let title = "Main Menu"

    func makeMenu() -> [Menu] {
       return [
            Menu(items: [
                MenuItem(
                    title: "Async Workflows",
                    viewControllerProvider: {
                        return MenuViewController(menuBuilder: AsyncDemoMenuBuilder())
                    }
                ),
                MenuItem(
                    title: "Progress Views",
                    viewControllerProvider: {
                        return MenuViewController(menuBuilder: CircularProgressViewMenuBuilder())
                    }
                )
            ])
        ]
    }
}
