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

// the states of the timer
enum BindTimerState: String {
    case idle // ie timer not running
    case running
}

// format for saving each "this bind" session
struct BindSession: Identifiable, Equatable {
    let id = UUID()
    let startDate: Date
    var durationSeconds: Int
}

// this is to load generated data from json
private struct BindSessionDTO: Codable {
    let id: UUID // or String if you prefer: let id: String
    let startDate: Date
    let durationSeconds: Int
}

/*
 calculates properties -> how much time passed and left in time limit (seconds value and formated strings hh:mm:ss), fraction of time passed vs time limit
 public methods -> start(), stop()
 public varaibles -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
 private methods -> _createTimer(), _killTimer(), _onTick(), _formatSeconds(_ seconds:Int), _totalSeconds(on day: Date)
 */
@Observable // declares everything publically accessible in class acts as state var
// With @​Observable, stored properties are observable by default. Changes to those properties will trigger view updates when the object is used in a SwiftUI view.

class BindTimer{
    // initialize states, variables, timer --------------------------------------------
    
    // timer
    private var _state: BindTimerState = .idle
    private var _timer: Timer?
    
    // tracking variables (all history)
    private var _bindSessionHistory: [BindSession] = [] // public and observable array of all bind sessions
    
    // tracking variables (today)
    private var _secondsPassedToday: Int = 0
    private var _fractionPassedToday: Double = 0
    private var _secondsPassedPreviouslyToday: Int { // computed value that recalculates every time accessed
        _totalSeconds(on: Date()) // calls private function totalSeconds()
    }
    // tracking variables (this bind)
    private var _secondsPassedThisBind: Int = 0
    private var _dateStartedThisBind: Date = Date.now
    private var _numberOfNotificationsSent: Int = 0
    
    // limit variables (today)
    private var _secondsBindLimit: TimeInterval = 20 // where 8 hour limit will go
    
    // limit variables (this bind)
    private var _notificationLimit: Int = 3
    private var _secondsBetweenNotifications: TimeInterval = 10 // this value now for testing
    
    // Initialize public properties (can access outside of this class) ---------------------------
    // this setup of public properties = private properties, allows private properties to be viewed but not changed outside of this class
    var secondsPassedToday: Int{
        return _secondsPassedToday
    }
    var secondsPassedTodayString: String {
        return _formatSeconds(_secondsPassedToday)
    }
    var secondsLeftToday: Int{
        Int(_secondsBindLimit) - _secondsPassedToday
    }
    var secondsLeftTodayString: String{
        return _formatSeconds(secondsLeftToday)
    }
    var fractionPassedToday: Double {
        return _fractionPassedToday
    }
    var fractionLeftToday: Double{
        1 - _fractionPassedToday
    }
    var bindSessionHistory: [BindSession] {
        return _bindSessionHistory
    }
    var state: BindTimerState{
        _state
    }
    var secondsPassedThisBind: Int { // making public for testing
        return _secondsPassedThisBind
    }
    
    init() {
        loadHistoryFromBundleJSON()
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
        // append seconds passed this bind to the list of bind history
        _secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        _bindSessionHistory.append(BindSession(startDate: _dateStartedThisBind, durationSeconds: _secondsPassedThisBind))

        // stop timer
        _secondsPassedThisBind = 0
        _state = .idle
        _killTimer()
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
        // cancel pending limit notifications
        BindTimerNotification.cancelScheduledLimitNotifications()
    }
    
    // updates private variables every tick
    private func _onTick(){
        self._secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        self._secondsPassedToday = self._secondsPassedThisBind + self._secondsPassedPreviouslyToday
        
        // update fraction
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
    // formats our seconds variables into hh, mm, ss (could we use a built in function for this instead?)
    private func _formatSeconds(_ seconds:Int) -> String {
        if seconds <= 0 {
            return "00:00:00"
        }
        let hh: Int = seconds / 3600
        let mm: Int = (seconds % 3600) / 60
        let ss: Int = seconds % 60
        return String(format: "%02d:%02d:%02d", hh, mm, ss)
    }
    
    // totals bind times for any day
    private func _totalSeconds(on day: Date) -> Int {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: day)
        return _bindSessionHistory
            .filter { cal.isDate($0.startDate, inSameDayAs: startOfDay) }
            .reduce(0) { $0 + $1.durationSeconds }
    }
    
    private func loadHistoryFromBundleJSON(fileName: String = "generatedBindData") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("generatedBindData.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode([BindSessionDTO].self, from: data)

            // Map DTO -> BindSession (we ignore the JSON id and generate our own UUID like your struct does)
            let mapped = decoded.map { dto in
                BindSession(startDate: dto.startDate, durationSeconds: dto.durationSeconds)
            }

            // Replace or append, depending on your needs:
            self._bindSessionHistory = mapped

            // Optionally recompute today's running totals immediately
            self._secondsPassedToday = self._totalSeconds(on: Date())
            self._fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
        } catch {
            print("Failed to decode generatedBindData.json: \(error)")
        }
    }
}

private struct BindTimerKey: EnvironmentKey {
    static let defaultValue = BindTimer()
}

extension EnvironmentValues {
    var bindTimer: BindTimer {
        get { self[BindTimerKey.self] }
        set { self[BindTimerKey.self] = newValue }
    }
}

extension BindTimer {
    // Creates `days` days of fake sessions before today.
    // Each day gets `sessionsPerDay` sessions with random durations.
    func seedFakeHistory(days: Int = 7, sessionsPerDay: Int = 2, durationRange: ClosedRange<Int> = 5...1800) {
        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 1...days {
            // Target date is N days before today
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: day)

            for s in 0..<sessionsPerDay {
                // Stagger start times within the day (e.g., morning & afternoon)
                let hour = s == 0 ? 9 : 15 // 9 AM and 3 PM
                var components = calendar.dateComponents([.year, .month, .day], from: startOfDay)
                components.hour = hour
                components.minute = Int.random(in: 0..<60)
                components.second = Int.random(in: 0..<60)

                let startDate = calendar.date(from: components) ?? startOfDay
                let duration = Int.random(in: durationRange)

                _bindSessionHistory.append(
                    BindSession(startDate: startDate, durationSeconds: duration)
                )
            }
        }
    }
}
