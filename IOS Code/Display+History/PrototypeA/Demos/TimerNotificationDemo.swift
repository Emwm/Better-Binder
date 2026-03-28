//
//  TimerNotificationDemo.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/2/26.
//  based on playlist https://www.youtube.com/watch?v=bA_62sNHBoc&list=PLpSG4DtJWIHW1BHjqM6xqEF1jw4h1noYj&index=3
//

/*
 UI to test just notification logic in BinderTimerNotification
 */

import SwiftUI

// helps user allow notifications, creates a button to send notications, creates button that leads users to settings to enable notifications, and sends pop up to help them enable notifications when they have the app open
struct TimerNotificationDemo: View{
    // these are to help user allow notifications
    @State private var showWarning = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View{
        VStack{
            Button ("send notification"){
                BindTimerNotification.scheduleNotification(identifier: "my-notification", seconds: 5, title: "Test notification", body: "Some message")
            }
            // this is to help user allow notifications, through a enable button that leads to settings
            if showWarning{
                Text ("Notifications are disabled")
                Button ("Enable"){
                    //open settings using app url in settings
                    DispatchQueue.main.async {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options:[:], completionHandler: nil)
                    }
                }
            }
        }
        // this is to help user allow notifications with pop up on the screen to enable notifications
        .onChange(of: scenePhase) {
            if scenePhase == .active{ // only shows permission ask when on this page aka scene phase
                //only show warning when not authorized
                BindTimerNotification.checkAuthorization{ authorized in showWarning = !authorized}
            }
        }
    }
}
