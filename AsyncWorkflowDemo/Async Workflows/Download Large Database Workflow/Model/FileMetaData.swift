//
//  Created by Brian Coyner on 8/10/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation

struct FileMetaData {

    let group: String
    let category: String
    let revision: Int
}

extension FileMetaData: CustomDebugStringConvertible {

    var debugDescription: String {
        return "File Meta Data: \(group); \(category); \(revision)"
    }
}
