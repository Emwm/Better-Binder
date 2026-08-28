//
//  JournalEntryModel.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 8/28/26.
//

import Foundation
import SwiftData

@Model
class JournalEntry{
    var timestamp: Date
    var text: String
    var physicalWellness: Int
    var mentalWellness: Int
    
    init(timestamp: Date, text: String, physicalWellness: Int, mentalWellness: Int) {
        self.timestamp = timestamp
        self.text = text
        self.physicalWellness = physicalWellness
        self.mentalWellness = mentalWellness
    }
}
