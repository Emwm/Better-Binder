//
//  BindTimer.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/2/26.
//

/*
 Used this playlist of tutorials:  https://www.youtube.com/watch?v=AFeo84CgRRQ&list=PLpSG4DtJWIHW1BHjqM6xqEF1jw4h1noYj&index=4
 and built in AI on XCode
 
 Summary: BindTimer with two states (idle and running) tracks time of each session (from start to stop), updates bind history data model after every bind session, constantly calculates total time passed (as well as fraction of time passed vs time limit) for todays date, and sends notifications when a time limit is reached
 
 To Update:
 - need to consider behavior at midnight, will it be appended with previous days date or split into two different bind sessions?
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

// this is to load generated data from json
private struct BindSessionDTO: Codable {
    let startDate: Date
    let durationSeconds: Int
}

/*
 public methods -> start(), stop(), setDailyBindLimit()
 public varaibles -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindTimerState, secondsPassedThisBind
 private methods -> _createTimer(), _killTimer(), _onTick(), _totalSeconds(on day: Date)
 */
@Observable // declares everything publically accessible in class acts as state var
// With @​Observable, stored properties are observable by default. Changes to those properties will trigger view updates when the object is used in a SwiftUI view.

class BindTimer{
    // initialize states, variables, timer --------------------------------------------
    
    // data model setup
    var modelContext: ModelContext
    
    // user defaults to help with persistance
    private let kActiveBindStartDateKey = "activeBindStartDate"
    private let kIsBindRunningKey = "isBindRunning"
    
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
    var secondsPassedThisBind: Int {
        return _secondsPassedThisBind
    }
    var secondsBindLimit: Double {
        return _secondsBindLimit
    }
    
    // initialize values, these will overwrite default values established above if there is persisted data
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _seedDataIfNeeded(context: modelContext)
        
        // to setup user defaults for data persistance
        if UserDefaults.standard.bool(forKey: kIsBindRunningKey),
           let savedDate = UserDefaults.standard.object(forKey: kActiveBindStartDateKey) as? Date {
            // load saved data
            _dateStartedThisBind = savedDate // load saved value
            
            // set state
            _state = .running // will this overide bind manager?
            
            // recompute derived values
            _secondsPassedThisBind = Int(Date.now.timeIntervalSince(savedDate))
            _secondsPassedPreviouslyToday = _totalSeconds(on: Date())
            _secondsPassedToday = _secondsPassedThisBind + _secondsPassedPreviouslyToday
            _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
            
            // create the timer
            _createTimer()
        } else {
            _state = .idle // will this overide bind manager?
        }
    }
    
    // Public Methods (accessible outside of this class) --------------------------------------------
   
    // resets timer values and starts timer
    func start(){
        // track start of this bind
        _dateStartedThisBind = Date.now
        // update user defaults for persistance
        UserDefaults.standard.set(_dateStartedThisBind, forKey: kActiveBindStartDateKey)
        UserDefaults.standard.set(true, forKey: kIsBindRunningKey)
        // start timer
        _state = .running
        _createTimer()
    }
    
    // saves time passed this bind to bindsessionhistory model and stops timer
    func stop(){
        // recalculate seconds passed this bind before saving, to ensure accuracy
        _secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        
        // only add to data set if it is greater than 2 seconds
        if _secondsPassedThisBind > 2 {
            addBindSession(startDate: _dateStartedThisBind, durationSeconds: _secondsPassedThisBind)
        }

        // stop timer
        _secondsPassedThisBind = 0
        _state = .idle
        _killTimer()
        
        // reset user defaults for persistance
        UserDefaults.standard.removeObject(forKey: kActiveBindStartDateKey)
        UserDefaults.standard.set(false, forKey: kIsBindRunningKey)
    }
    
    func setDailyBindLimit(seconds: TimeInterval) {
        _secondsBindLimit = seconds
        
        // Recompute derived values that depend on the limit
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
    func addBindSession(startDate: Date, durationSeconds: Int){
        let newTimeSession = BindSession(startDate: startDate, durationSeconds: durationSeconds)
        modelContext.insert(newTimeSession) // add to data model
        do { // help it to prompt to save to data model
            try modelContext.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    func deleteBindSession(_ item: BindSession){
        modelContext.delete(item) //remove from data model
        do { // help it to prompt a save to data model
            try modelContext.save()
        } catch {
            print("Save failed: \(error)")
        }
        // Recompute derived values...
        self._secondsPassedPreviouslyToday = _totalSeconds(on: Date())
        self._secondsPassedToday = self._secondsPassedThisBind + self._secondsPassedPreviouslyToday
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
    // Private Methods (accessible only inside of this class) --------------------------------------------

    // creates the timer and schedules notifications for when time limit is reached
    private func _createTimer(){
        // create timer (note repeats = true for continuous timer in background)
        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?._onTick() // called every second
        }
        
        // Ensure derived state is up to date before scheduling
        self._secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        self._secondsPassedPreviouslyToday = _totalSeconds(on: Date())
        self._secondsPassedToday = self._secondsPassedThisBind + self._secondsPassedPreviouslyToday
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))

        BindTimerNotification.cancelScheduledLimitNotifications() // cancel old notifications
        _scheduleLimitNotifications() //schedule new notifications
        
    }
    
    // if a timer exists it gets rid of it and kills notifications
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
    
    private func _scheduleLimitNotifications() {
        // Always compute fresh ‘secondsLeftToday’ based on current derived state
        // Here, secondsLeftToday is derived from _secondsPassedToday and _secondsBindLimit
        // Make sure _secondsPassedToday is up to date before calling this method.
        if secondsLeftToday > 0 {
            BindTimerNotification.scheduleNotification(
                identifier: "time-limit-notification-1",
                seconds: TimeInterval(secondsLeftToday),
                title: "Limit Reached",
                body: "You have binded for 8 hours today, please loosen binder for the rest of the day"
            )
            BindTimerNotification.scheduleNotification(
                identifier: "time-limit-notification-2",
                seconds: TimeInterval(secondsLeftToday) + _secondsBetweenNotifications,
                title: "Limit Reached",
                body: "You have binded for 8 hours today, please loosen binder for the rest of the day"
            )
            BindTimerNotification.scheduleNotification(
                identifier: "time-limit-notification-3",
                seconds: TimeInterval(secondsLeftToday) + Double(2) * _secondsBetweenNotifications,
                title: "Limit Reached",
                body: "You have binded for 8 hours today, please loosen binder for the rest of the day"
            )
        } else {
            // If already at/over limit, schedule soon
            BindTimerNotification.scheduleNotification(
                identifier: "time-limit-notification-1",
                seconds: 2,
                title: "Limit Reached",
                body: "You have binded for 8 hours today, please loosen binder for the rest of the day"
            )
            BindTimerNotification.scheduleNotification(
                identifier: "time-limit-notification-2",
                seconds: 2 + _secondsBetweenNotifications,
                title: "Limit Reached",
                body: "You have binded for 8 hours today, please loosen binder for the rest of the day"
            )
            BindTimerNotification.scheduleNotification(
                identifier: "time-limit-notification-3",
                seconds: 2 + Double(2) * _secondsBetweenNotifications,
                title: "Limit Reached",
                body: "You have binded for 8 hours today, please loosen binder for the rest of the day"
            )
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
