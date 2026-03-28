//
//  Prototype_B_SwiftDataApp.swift
//  Prototype-B-SwiftData
//
//  Created by Reese Brogden on 3/16/26.
//

import SwiftUI
import SwiftData

@main
struct Prototype_B_SwiftDataApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [BindSessionModel.self]) //can also inject an array of all your models
        // injecting at the root of your app , so that all subviews have access to this context
    }
}
