//
//  BindTimer.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/2/26.
//

/*
 Used this playlist of tutorials:  https://www.youtube.com/watch?v=AFeo84CgRRQ&list=PLpSG4DtJWIHW1BHjqM6xqEF1jw4h1noYj&index=4
 and built in AI on XCode
 
 Summary: BindTimer with two states (idle and running) tracks time of each session (from start to stop), updates history list after every bind session, constantly calculates total time passed (as well as fraction of time passed vs time limit) for todays date, and sends notifications when a time limit is reached
 
 To Update:
 - need to consider behavior at midnight, will it be appended with previous days date or split into two different bind sessions?
 - do we want the ability to delete entries if there is a glitch?
 - use swift data to have data persistance (make the test functionality so that theres an entry box for simulating data as well with entrie spots for # days previous to today, # seconds passed, # start time?)
 */

import Foundation
import Observation
import SwiftUI
import SwiftData

// the states of the timer
enum BindTimerState: String {
    case idle // ie timer not running
    case running
}

// format for saving each "this bind" session
//struct BindSession: Identifiable, Equatable {
//    let id = UUID()
//    let startDate: Date
//    var durationSeconds: Int
//}

// this is to load generated data from json
private struct BindSessionDTO: Codable {
    let startDate: Date
    let durationSeconds: Int
}

/*
 calculates properties -> how much time passed and left in time limit (seconds value and formated strings hh:mm:ss), fraction of time passed vs time limit
 public methods -> start(), stop(), setDailyBindLimit()
 public varaibles -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
 private methods -> _createTimer(), _killTimer(), _onTick(), _totalSeconds(on day: Date)
 */
@Observable // declares everything publically accessible in class acts as state var
// With @​Observable, stored properties are observable by default. Changes to those properties will trigger view updates when the object is used in a SwiftUI view.

class BindTimer{
    // initialize states, variables, timer --------------------------------------------
    
    // data model setup
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _seedDataIfNeeded(context: modelContext)
    }
    
    // old list based stuff
    //    // tracking variables (all history)
    //    private var _bindSessionHistory: [BindSession] = [] // public and observable array of all bind sessions
    
    // timer
    private var _state: BindTimerState = .idle
    private var _timer: Timer?
    
    // tracking variables (today)
    private var _secondsPassedToday: Int = 0
    private var _fractionPassedToday: Double = 0
    private var _secondsPassedPreviouslyToday: Int = 0
    // tracking variables (this bind)
    private var _secondsPassedThisBind: Int = 0
    private var _dateStartedThisBind: Date = Date.now
    private var _numberOfNotificationsSent: Int = 0
    
    // limit variables (today)
    private var _secondsBindLimit: TimeInterval = 60*60*6 // where 8 hour limit will go
    
    // limit variables (this bind)
    private var _notificationLimit: Int = 3
    private var _secondsBetweenNotifications: TimeInterval = 60*30 // this value now for testing
    
    // Initialize public properties (can access outside of this class) ---------------------------
    // this setup of public properties = private properties, allows private properties to be viewed but not changed outside of this class
    var secondsPassedToday: Int{
        return _secondsPassedToday
    }
    var secondsPassedTodayString: String {
        return _secondsPassedToday.asTimestamp()
    }
    var secondsLeftToday: Int{
        Int(_secondsBindLimit) - _secondsPassedToday
    }
    var secondsLeftTodayString: String{
        return secondsLeftToday.asTimestamp()
    }
    var fractionPassedToday: Double {
        return _fractionPassedToday
    }
    var fractionLeftToday: Double{
        1 - _fractionPassedToday
    }
    var state: BindTimerState{
        _state
    }
    var secondsPassedThisBind: Int { // making public for testing
        return _secondsPassedThisBind
    }
    var secondsBindLimit: Double {
        return _secondsBindLimit
    }
    
    // Public Methods (accessible outside of this class) --------------------------------------------
   
    // resets timer values and starts timer
    func start(){
        _dateStartedThisBind = Date.now
        _secondsPassedThisBind = 0
        _state = .running
        _createTimer()
    }
    
    // saves time passed this bind to bindsessionhistory list and stops timer
    func stop(){
        _secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        
        // old
//        _bindSessionHistory.append(BindSession(startDate: _dateStartedThisBind, durationSeconds: _secondsPassedThisBind))
        addBindSession(startDate: _dateStartedThisBind, durationSeconds: _secondsPassedThisBind)

        // stop timer
        _secondsPassedThisBind = 0
        _state = .idle
        _killTimer()
    }
    
    func setDailyBindLimit(seconds: TimeInterval) {
        _secondsBindLimit = seconds
        
        // Recompute derived values that depend on the limit
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
    func addBindSession(startDate: Date, durationSeconds: Int){
        let newTimeSession = BindSession(startDate: startDate, durationSeconds: durationSeconds)
        modelContext.insert(newTimeSession) // saves to persistant storage
    }
    
    func deleteBindSession(_ item: BindSession){
        modelContext.delete(item)
        self._secondsPassedToday = _totalSeconds(on: Date())
    }
    
    // Private Methods (accessible only inside of this class) --------------------------------------------

    // creates the timer and schedules notifications for when time limit is reached
    private func _createTimer(){
        // create timer (note repeats = true for continuous timer in background)
        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?._onTick() // called every second
        }
        
        // schedule notifications (should make this into a for loop or add private function helper
        if secondsLeftToday > 0 {
            // schedules notifications (note if timeLeftToday==0 at start of this timer, the notifications will be sent right away)
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-1", seconds: TimeInterval(secondsLeftToday), title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-2", seconds: TimeInterval(secondsLeftToday) + _secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-3", seconds: TimeInterval(secondsLeftToday) + Double(2)*_secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            
            // for loop below does not work for some reason
    //        // schedules i notifications starting when seconds left runs out, evenly spaced by secondsBetweenNotifications
    //        for i in 1..._notificationLimit{
    //            let id = "time-limit-notification-\(i)"
    //            BindTimerNotification.scheduleNotification(identifier: id, seconds: TimeInterval(secondsLeft) + Double(i)*_secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
    //        }
        } else { // need a buffer, can not schedule notification in 0 seconds
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-1", seconds: 2, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-2", seconds: 2 + _secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-3", seconds: 2 + Double(2)*_secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
        }
    }
    
    // if a timer exists it gets rid of it
    private func _killTimer(){
        _timer?.invalidate()
        _timer = nil
        BindTimerNotification.cancelScheduledLimitNotifications() // cancel pending limit notifications
    }
    
    // updates private variables every tick
    private func _onTick(){
        self._secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        self._secondsPassedPreviouslyToday = _totalSeconds(on: Date())
        self._secondsPassedToday = self._secondsPassedThisBind + self._secondsPassedPreviouslyToday
        
        // update fraction
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
    // Your function now lives inside the class and queries the persistent storage
    private func _totalSeconds(on day: Date) -> Int {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: day)
        let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch sessions specifically for this day from the database
        let predicate = #Predicate<BindSession> {
            $0.startDate >= startOfDay && $0.startDate < endOfDay
        }
        
        let descriptor = FetchDescriptor<BindSession>(predicate: predicate)
        
        do {
            let dailySessions = try modelContext.fetch(descriptor)
            return dailySessions.reduce(0) { $0 + $1.durationSeconds }
        } catch {
            print("Fetch failed: \(error)")
            return 0
        }
    }
    
    // old
    private func _seedDataIfNeeded(context: ModelContext) {
        // 1. Check if we already have data
        let descriptor = FetchDescriptor<BindSession>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        // 2. Only proceed if the database is empty
        guard existingCount == 0 else {
            print("Database already has data. Skipping seed.")
            return
        }
        
        // 3. Your existing JSON logic
        guard let url = Bundle.main.url(forResource: "generatedBindData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedDTOs = try decoder.decode([BindSessionDTO].self, from: data)
            
            // 4. Map and Insert into the context
            for dto in decodedDTOs {
                let newSession = BindSession(
                    startDate: dto.startDate,
                    durationSeconds: dto.durationSeconds
                )
                context.insert(newSession)
            }
            
            // 5. Save the changes to the phone's disk
            try context.save()
            print("Successfully seeded \(decodedDTOs.count) sessions.")
            
        } catch {
            print("Seeding failed: \(error)")
        }
    }
}

//private struct BindTimerKey: EnvironmentKey {
//    static let defaultValue = BindTimer()
//}
//
//extension EnvironmentValues {
//    var bindTimer: BindTimer {
//        get { self[BindTimerKey.self] }
//        set { self[BindTimerKey.self] = newValue }
//    }
//}

// old
//extension BindTimer {
//    // Creates `days` days of fake sessions before today.
//    // Each day gets `sessionsPerDay` sessions with random durations.
//    func seedFakeHistory(days: Int = 7, sessionsPerDay: Int = 2, durationRange: ClosedRange<Int> = 5...1800) {
//        let calendar = Calendar.current
//        let now = Date()
//
//        for dayOffset in 1...days {
//            // Target date is N days before today
//            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
//            let startOfDay = calendar.startOfDay(for: day)
//
//            for s in 0..<sessionsPerDay {
//                // Stagger start times within the day (e.g., morning & afternoon)
//                let hour = s == 0 ? 9 : 15 // 9 AM and 3 PM
//                var components = calendar.dateComponents([.year, .month, .day], from: startOfDay)
//                components.hour = hour
//                components.minute = Int.random(in: 0..<60)
//                components.second = Int.random(in: 0..<60)
//
//                let startDate = calendar.date(from: components) ?? startOfDay
//                let duration = Int.random(in: durationRange)
//
//                _bindSessionHistory.append(
//                    BindSession(startDate: startDate, durationSeconds: duration)
//                )
//            }
//        }
//    }
//}
