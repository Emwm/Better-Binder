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
    private var _cachedTotalToday: Int = 0
    
    // tracking variables (this bind)
    private var _secondsPassedThisBind: Int = 0
    private var _dateStartedThisBind: Date = Date.now
    private var _numberOfNotificationsSent: Int = 0
    
    // limit variables (today)
    private var _secondsBindLimit: TimeInterval = 60*60*8 // where 8 hour limit will go
    
    // limit variables (this bind)
    private var _notificationLimit: Int = 3
    private var _secondsBetweenNotifications: TimeInterval = 60*30
    
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
            _cachedTotalToday = _calculateCachedTotalToday()
            _secondsPassedToday = _secondsPassedThisBind + _cachedTotalToday
            _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
            
            // create the timer
            _createTimer()
        } else {
            _state = .idle // will this overide bind manager?
            
            // Preload for idle UI
            _cachedTotalToday = _calculateCachedTotalToday()
            _secondsPassedToday = _cachedTotalToday
            _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
        }
    }
    
    // Public Methods (accessible outside of this class) --------------------------------------------
   
    // updates the daily total binding time
    func updateDailyTotal(for date: Date, adding seconds: Int) {
        let day = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailyTotal>(
            predicate: #Predicate { $0.day == day }
        )
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                existing.totalSeconds += seconds
            } else {
                let new = DailyTotal(day: day, totalSeconds: seconds)
                modelContext.insert(new)
            }
            try modelContext.save()
        } catch {
            // handle errors appropriately (log, assert, etc.)
            print("Failed to update daily total: \(error)")
        }
    }
    
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
        // recalculate before saving, to ensure accuracy
        _secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        _cachedTotalToday += _secondsPassedThisBind
        _secondsPassedToday = _cachedTotalToday
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
        
        // only add to data set if it is greater than 2 seconds
        if _secondsPassedThisBind > 2 {
            addBindSession(startDate: _dateStartedThisBind, durationSeconds: _secondsPassedThisBind) //save this sessin to bindsession model
            updateDailyTotal(for: _dateStartedThisBind, adding: _secondsPassedThisBind) //update todays bind total to dailytotal model
        }

        // stop timer
        _state = .idle
        _killTimer()
        
        // reset this session
        self._secondsPassedThisBind = 0
        
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
    
    func deleteBindSession(_ item: BindSession) {
        let duration = item.durationSeconds
        let day = Calendar.current.startOfDay(for: item.startDate)

        modelContext.delete(item)
        do {
            // Reduce the cached total for that day
            let descriptor = FetchDescriptor<DailyTotal>(
                predicate: #Predicate { $0.day == day }
            )
            if let existing = try modelContext.fetch(descriptor).first {
                existing.totalSeconds = max(0, existing.totalSeconds - duration)
            }
            try modelContext.save()
        } catch {
            print("Save failed: \(error)")
        }

        // Update derived values for today
        self._cachedTotalToday = _calculateCachedTotalToday()
        self._secondsPassedToday = _cachedTotalToday + self._secondsPassedThisBind
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
        self._secondsPassedToday = self._secondsPassedThisBind + _cachedTotalToday
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
        self._secondsPassedToday = self._secondsPassedThisBind + _cachedTotalToday
        
        // update fraction
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
//    // queries the bindsession model and calculates total seconds binded for that day
//    private func _totalSeconds(on day: Date) -> Int {
//        let cal = Calendar.current
//        let startOfDay = cal.startOfDay(for: day)
//        let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!
//        
//        // Fetch sessions specifically for this day from the database
//        let predicate = #Predicate<BindSession> {
//            $0.startDate >= startOfDay && $0.startDate < endOfDay
//        }
//        
//        let descriptor = FetchDescriptor<BindSession>(predicate: predicate)
//        
//        do {
//            let dailySessions = try modelContext.fetch(descriptor)
//            return dailySessions.reduce(0) { $0 + $1.durationSeconds }
//        } catch {
//            print("Fetch failed: \(error)")
//            return 0
//        }
//    }
    
    
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
    
    //
    private func _calculateCachedTotalToday() -> Int {
        let day = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyTotal>(
            predicate: #Predicate { $0.day == day }
        )
        do {
            return try modelContext.fetch(descriptor).first?.totalSeconds ?? 0
        } catch {
            print("Failed to read DailyTotal: \(error)")
            return 0
        }
    }
}

    // seed the generated data
    private func _seedDataIfNeeded(context: ModelContext) {
        // 1. Check if we already have data
        let sessionDescriptor = FetchDescriptor<BindSession>()
        let existingCount = (try? context.fetchCount(sessionDescriptor)) ?? 0
        guard existingCount == 0 else {
            print("Database already has data. Skipping seed.")
            return
        }

        // 2. Load your JSON
        guard let url = Bundle.main.url(forResource: "generatedBindData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("No generatedBindData.json found or unreadable.")
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedDTOs = try decoder.decode([BindSessionDTO].self, from: data)

            // 3. Insert sessions and accumulate daily totals
            let cal = Calendar.current
            var dayTotals: [Date: Int] = [:] // startOfDay -> totalSeconds

            for dto in decodedDTOs {
                // Insert BindSession
                let newSession = BindSession(startDate: dto.startDate, durationSeconds: dto.durationSeconds)
                context.insert(newSession)

                // Accumulate into dayTotals
                let day = cal.startOfDay(for: dto.startDate)
                dayTotals[day, default: 0] += dto.durationSeconds
            }

            // 4. Upsert DailyTotal for each day
            for (day, total) in dayTotals {
                let totalDescriptor = FetchDescriptor<DailyTotal>(
                    predicate: #Predicate { $0.day == day }
                )
                if let existing = try context.fetch(totalDescriptor).first {
                    existing.totalSeconds += total
                } else {
                    let newDaily = DailyTotal(day: day, totalSeconds: total)
                    context.insert(newDaily)
                }
            }

            // 5. Save once at the end
            try context.save()
            print("Successfully seeded \(decodedDTOs.count) sessions and updated \(dayTotals.count) daily totals.")

        } catch {
            print("Seeding failed: \(error)")
        }
    }
