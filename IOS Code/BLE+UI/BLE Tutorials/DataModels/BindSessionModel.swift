//
//  BindSessionModel.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/7/26.
//

import Foundation
import SwiftData

@Model
class BindSession{
    var startDate: Date
    var durationSeconds: Int
    
    init(startDate: Date, durationSeconds: Int) {
        self.startDate = startDate
        self.durationSeconds = durationSeconds
    }
}
