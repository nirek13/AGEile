//
//  Item.swift
//  AGEile
//
//  Created by Pavan Shetty on 2024-10-27.
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
