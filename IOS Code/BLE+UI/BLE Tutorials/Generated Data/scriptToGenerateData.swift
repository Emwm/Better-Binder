//
//  scriptToGenerateData.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/8/26.
//

// open a playground in xcode and run this, then copy the text in the terminal

//import Foundation
//
//// 1. Setup our Data Model
//struct BindSession: Identifiable, Codable {
//    let id: UUID
//    let startDate: Date
//    var durationSeconds: Int
//}
//
//func generateJSON() {
//    var sessions: [BindSession] = []
//    let calendar = Calendar.current
//    
//    // Define the date range
//    let startDate = calendar.date(from: DateComponents(year: 2026, month: 2, day: 1))!
//    let endDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 7))!
//    
//    var currentDate = startDate
//    
//    while currentDate <= endDate {
//        // Randomize 1 to 5 sessions per day
//        let sessionCount = Int.random(in: 1...5)
//        
//        // Total duration for the day: 1200 to 32400 (Target average ~28800)
//        // We use a weighted random to pull towards the 28800 average
//        let totalDayDuration = Int.random(in: 1200...32400)
//        
//        var remainingDuration = totalDayDuration
//        
//        for i in 1...sessionCount {
//            let sessionDuration: Int
//            if i == sessionCount {
//                sessionDuration = remainingDuration
//            } else {
//                // Split the remaining time, ensuring at least some time is left for others
//                sessionDuration = Int.random(in: 1...max(1, remainingDuration - (sessionCount - i)))
//                remainingDuration -= sessionDuration
//            }
//            
//            // Randomize the time of day (8 AM to 8 PM)
//            let hour = Int.random(in: 8...20)
//            let minute = Int.random(in: 0...59)
//            let sessionDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate)!
//            
//            let session = BindSession(id: UUID(), startDate: sessionDate, durationSeconds: sessionDuration)
//            sessions.append(session)
//        }
//        
//        // Move to the next day
//        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
//    }
//    
//    // 2. Encode to JSON
//    let encoder = JSONEncoder()
//    encoder.dateEncodingStrategy = .iso8601
//    encoder.outputFormatting = .prettyPrinted
//    
//    if let data = try? encoder.encode(sessions),
//       let jsonString = String(data: data, encoding: .utf8) {
//        print(jsonString)
//    }
//}
//
//generateJSON()

