//
//  Created by Brian Coyner on 5/9/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation
import UIKit

struct MenuItem {
    let title: String
    let viewControllerProvider: () -> UIViewController
}
