//
//  BindSession.swift
//  Prototype-B-SwiftData
//
//  Created by Reese Brogden on 3/16/26.
//

import Foundation
import SwiftData
// Note swift data works for iphones no older than 2020

@Model // macro for treating bind sessions as persistant data
// data model for saving each "this bind" session
final class BindSessionModel {
    @Attribute(.unique) var id: UUID // the attribute and unique makes sure no two entries have the same id
    var startDate: Date
    var durationSeconds: Int
    
    // need this initializer unlike normal struct
    init(id: UUID = UUID(), startDate: Date, durationSeconds: Int) {
        self.id = id
        self.startDate = startDate
        self.durationSeconds = durationSeconds
    }
}

// Container is where your data is persisted
// Context is like your working changes, and then when you save it it gets saved to the container and now it persists
