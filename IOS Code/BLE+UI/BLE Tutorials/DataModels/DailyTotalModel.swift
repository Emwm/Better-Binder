//
//  DailyTotalModel.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 8/25/26.
//

import SwiftData
import Foundation

@Model
final class DailyTotal {
    @Attribute(.unique) var day: Date // start-of-day, .unique ensures one record per day
    var totalSeconds: Int
    
//    @Relationship
//    var BindSessionModels: [BindSession]

    init(day: Date, totalSeconds: Int) {
        self.day = Calendar.current.startOfDay(for: day)
        self.totalSeconds = totalSeconds
    }
}
