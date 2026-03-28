//
//  BindTimer.swift
//  Prototype-B-SwiftData
//
//  Created by Reese Brogden on 3/16/26.
//

import Foundation
import Observation
import SwiftData

// the states of the timer
enum BindTimerState: String {
    case idle // ie timer not running
    case running
}

/*
 calculates properties -> how much time passed and left in time limit (seconds value and formated strings hh:mm:ss), fraction of time passed vs time limit
 public methods -> start(), stop()
 public varaibles -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
 private methods -> _createTimer(), _killTimer(), _onTick(), _formatSeconds(_ seconds:Int), _totalSeconds(on day: Date)
 */
@Observable // declares everything publically accessible in class acts as state var
// With @​Observable, stored properties are observable by default. Changes to those properties will trigger view updates when the object is used in a SwiftUI view.
class BindTimer {
    // initialize private properties --------------------------------------------
    
    // context for the BindSessionModel to have persistance
    private let modelContext: ModelContext

    // timer
    private var _state: BindTimerState = .idle
    private var _timer: Timer?

    // tracking variables (today)
    private var _secondsPassedToday: Int = 0
    private var _fractionPassedToday: Double = 0
    private var _secondsPassedPreviouslyToday: Int { // computed value that recalculates every time accessed
        _totalSeconds(on: Date()) // calls private function totalSeconds()
    }

    // tracking variables (this bind)
    private var _secondsPassedThisBind: Int = 0
    private var _dateStartedThisBind: Date = Date.now

    // limits
    private var _secondsBindLimit: TimeInterval = 30
    private var _notificationLimit: Int = 3
    private var _secondsBetweenNotifications: TimeInterval = 20

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Initialize public properties (can access outside of this class) ---------------------------
    // this setup of public properties = private properties, allows private properties to be viewed but not changed outside of this class
    var secondsPassedToday: Int { _secondsPassedToday }
    var secondsPassedTodayString: String { _formatSeconds(_secondsPassedToday) }
    var secondsLeftToday: Int { Int(_secondsBindLimit) - _secondsPassedToday }
    var secondsLeftTodayString: String { _formatSeconds(secondsLeftToday) }
    var fractionPassedToday: Double { _fractionPassedToday }
    var fractionLeftToday: Double { 1 - _fractionPassedToday }
    var state: BindTimerState { _state }
    var secondsPassedThisBind: Int { _secondsPassedThisBind }

    // Public Methods (accessible outside of this class) --------------------------------------------
    func start() {
        _dateStartedThisBind = Date.now
        _secondsPassedThisBind = 0
        _state = .running
        _createTimer()
    }

    func stop() {
        // final update to this bind's duration
        _secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))

        // persist this bind session
        let session = BindSessionModel(
            startDate: _dateStartedThisBind,
            durationSeconds: _secondsPassedThisBind
        )
        modelContext.insert(session) // saves to swift data model
        do {
            try modelContext.save()
        } catch {
            // prints save error in terminal
            print("Failed to save BindSessionModel: \(error)")
        }

        // stop timer
        _secondsPassedThisBind = 0
        _state = .idle
        _killTimer()
    }
    
    // Private Methods (accessible only inside of this class) --------------------------------------------

    private func _createTimer() {
        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?._onTick() // called every second
        }
        _multipleNotifications()
    }

    // if a timer exists it gets rid of it
    private func _killTimer() {
        _timer?.invalidate()
        _timer = nil
    }

    // updates private variables every tick
    private func _onTick() {
        self._secondsPassedThisBind = Int(Date.now.timeIntervalSince(self._dateStartedThisBind))
        self._secondsPassedToday = self._secondsPassedThisBind + self._secondsPassedPreviouslyToday
        _fractionPassedToday = min(1, max(0, TimeInterval(_secondsPassedToday) / _secondsBindLimit))
    }
    
    private func _multipleNotifications() {
        // schedule notifications (should make this into a for loop)
        if secondsLeftToday > 0 {
            // schedules notifications (note if timeLeftToday==0 at start of this timer, the notifications will be sent right away)
            BindTimerNotification.scheduleNotification(identifier: "notification-1", seconds: TimeInterval(secondsLeftToday), title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-2", seconds: TimeInterval(secondsLeftToday) + _secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-3", seconds: TimeInterval(secondsLeftToday) + Double(2)*_secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
        } else { // need a buffer, can not schedule notification in 0 seconds
            BindTimerNotification.scheduleNotification(identifier: "notification-1", seconds: 10, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-2", seconds: 10 + _secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
            BindTimerNotification.scheduleNotification(identifier: "time-limit-notification-3", seconds: 10 + Double(2)*_secondsBetweenNotifications, title: "Limit Reached", body: "You have binded for 8 hours today, please loosen binder for the rest of the day")
        }
    }

    // formats our seconds variables into hh, mm, ss (could we use a built in function for this instead?)
    private func _formatSeconds(_ seconds:Int) -> String {
        if seconds <= 0 { return "00:00:00" }
        let hh = seconds / 3600
        let mm = (seconds % 3600) / 60
        let ss = seconds % 60
        return String(format: "%02d:%02d:%02d", hh, mm, ss)
    }

    // not sure how this function works i will check this
    // Fetch and sum sessions for a given day using Swift Data
    private func _totalSeconds(on day: Date) -> Int {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: day)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }

        let predicate = #Predicate<BindSessionModel> { session in
            session.startDate >= startOfDay && session.startDate < endOfDay
        }
        let descriptor = FetchDescriptor<BindSessionModel>(predicate: predicate)

        do {
            let sessions = try modelContext.fetch(descriptor)
            return sessions.reduce(0) { $0 + $1.durationSeconds }
        } catch {
            print("Fetch error: \(error)")
            return 0
        }
    }
}
