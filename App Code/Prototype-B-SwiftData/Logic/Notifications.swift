//
//  Notifications.swift
//  Prototype-B-SwiftData
//
//  Created by Reese Brogden on 3/16/26.
//

/*
 Used this playlist of tutorials:  https://www.youtube.com/watch?v=AFeo84CgRRQ&list=PLpSG4DtJWIHW1BHjqM6xqEF1jw4h1noYj&index=4
 
 Summary: class that sends notifications and checks if notifications are enabled
 
 To Update:
 - none as of now

 */

import Foundation
import UserNotifications

/*
  public methods ->
        checkAuthorization()
        scheduleNotification(identifier: , seconds: , title: , body: )
 */
class BindTimerNotification{
    
    // checks if notifications are enabled (functionality to help users enable notifications is in TimerNotificationDemo code)
    static func checkAuthorization(completion: @escaping (Bool)-> Void){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus{
            case .authorized:
                completion(true)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
                    completion(allowed)
                }
            default:
                completion(false)
            }
        }
    }
    
    // schedules a notification to send
    // parameters-> identifier string (ex "time-limit-notification"), seconds time interval (time to wait before sending), title and body strings
    static func scheduleNotification(identifier: String, seconds: TimeInterval, title: String, body: String){
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
}
