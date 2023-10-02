//
//  Item.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/2/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
