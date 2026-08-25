//
//  scriptToGenerateData.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/8/26.
//

// open a playground in xcode and run this, copy the text in the terminal, and paste into generatedBindData

/*
 Constraints in the script to generate data:
 
 - Date range: Jan 1, 2026 – Aug 23, 2026 (inclusive)
 - ~15% of days are randomly skipped; skipped days have no data
 - Recorded days contain 1–5 sessions
 - Each session is at least 20 minutes (1,200 seconds)
 - Maximum total session time per day: 9 hours (32,400 seconds)
 - Daily duration is randomly divided among that day's sessions
 - Sessions start randomly between 8:00 AM and 8:59 PM
 - Each session has a randomly generated UUID
 - JSON is sorted by startDate, oldest → newest
 - JSON properties appear as: id, startDate, durationSeconds
 
 */

//import Foundation
//
//// 1. Setup our Data Model
//
//struct BindSession: Identifiable, Codable {
//    let id: UUID
//    let startDate: Date
//    var durationSeconds: Int
//
//    // Ensure JSON properties appear in this order:
//    // id → startDate → durationSeconds
//    enum CodingKeys: String, CodingKey {
//        case id
//        case startDate
//        case durationSeconds
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(id, forKey: .id)
//        try container.encode(startDate, forKey: .startDate)
//        try container.encode(durationSeconds, forKey: .durationSeconds)
//    }
//}
//
//
//// 2. Generate the JSON
//
//func generateJSON() {
//
//    var sessions: [BindSession] = []
//
//    let calendar = Calendar.current
//
//    // Define the date range
//    let startDate = calendar.date(
//        from: DateComponents(
//            year: 2026,
//            month: 1,
//            day: 1
//        )
//    )!
//
//    let endDate = calendar.date(
//        from: DateComponents(
//            year: 2026,
//            month: 8,
//            day: 23
//        )
//    )!
//
//
//    // Probability of skipping a day
//    //
//    // 0.15 = 15% chance of skipping each day
//    //
//    // This produces roughly 4–5 missing days
//    // per 30-day month on average.
//    let skipProbability = 0.15
//
//
//    // Minimum duration for an individual session
//    // 20 minutes = 1200 seconds
//    let minimumSessionDuration = 20 * 60
//
//
//    // Maximum total duration for one day
//    // 9 hours = 32,400 seconds
//    let maximumDayDuration = 32_400
//
//
//    var currentDate = startDate
//
//
//    // 3. Generate sessions for each day
//
//    while currentDate <= endDate {
//
//        // Randomly skip this day
//        if Double.random(in: 0...1) < skipProbability {
//
//            // Move to the next day
//            currentDate = calendar.date(
//                byAdding: .day,
//                value: 1,
//                to: currentDate
//            )!
//
//            continue
//        }
//
//
//        // Randomize 1–5 sessions for this day
//        let sessionCount = Int.random(in: 1...5)
//
//
//        // Make sure there is enough total time
//        // for every session to be at least 20 minutes.
//        //
//        // Example:
//        // 5 sessions × 20 minutes = 100 minutes minimum
//        let minimumDayDuration =
//            sessionCount * minimumSessionDuration
//
//
//        // Generate the total amount of time spent
//        // on sessions for this day.
//        let totalDayDuration = Int.random(
//            in: minimumDayDuration...maximumDayDuration
//        )
//
//
//        var remainingDuration = totalDayDuration
//
//
//        // 4. Generate individual sessions
//
//        for i in 1...sessionCount {
//
//            let sessionDuration: Int
//
//
//            if i == sessionCount {
//
//                // The final session gets whatever time remains.
//                //
//                // Because the total duration was large enough,
//                // this will always be at least 20 minutes.
//                sessionDuration = remainingDuration
//
//            } else {
//
//                // Calculate how much time must be reserved
//                // for all remaining sessions.
//                let minimumRemainingDuration =
//                    (sessionCount - i) * minimumSessionDuration
//
//
//                // Maximum amount we can give this session
//                // while still leaving 20 minutes for each
//                // remaining session.
//                let maximumSessionDuration =
//                    remainingDuration - minimumRemainingDuration
//
//
//                // Generate a duration of at least 20 minutes.
//                sessionDuration = Int.random(
//                    in: minimumSessionDuration...maximumSessionDuration
//                )
//
//
//                remainingDuration -= sessionDuration
//            }
//
//
//            // 5. Randomize the time of day
//            //
//            // Sessions occur between 8 AM and 8 PM.
//            let hour = Int.random(in: 8...20)
//            let minute = Int.random(in: 0...59)
//
//
//            let sessionDate = calendar.date(
//                bySettingHour: hour,
//                minute: minute,
//                second: 0,
//                of: currentDate
//            )!
//
//
//            // 6. Create the session
//
//            let session = BindSession(
//                id: UUID(),
//                startDate: sessionDate,
//                durationSeconds: sessionDuration
//            )
//
//
//            sessions.append(session)
//        }
//
//
//        // Move to the next day
//        currentDate = calendar.date(
//            byAdding: .day,
//            value: 1,
//            to: currentDate
//        )!
//    }
//
//
//    // 7. Sort all sessions chronologically
//    //
//    // Oldest startDate → newest startDate
//    let sortedSessions = sessions.sorted {
//        $0.startDate < $1.startDate
//    }
//
//
//    // 8. Encode to JSON
//
//    let encoder = JSONEncoder()
//
//    // Store dates in ISO 8601 format
//    encoder.dateEncodingStrategy = .iso8601
//
//    // Make the JSON easier to read
//    encoder.outputFormatting = .prettyPrinted
//
//
//    if let data = try? encoder.encode(sortedSessions),
//       let jsonString = String(
//           data: data,
//           encoding: .utf8
//       ) {
//
//        print(jsonString)
//    }
//}
//
//
//// 9. Run the generator
//
//generateJSON()
