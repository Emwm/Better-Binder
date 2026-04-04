//
//  NotificationControlView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/28/26.
//

import SwiftUI

struct NotificationControlView: View{
    // these are to help user allow notifications
    @State private var showWarning = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View{
        VStack{
            Text("Enable Notifications")
                .font(.appHeader())
                .largePaddingTop()
                .largePaddingBottom()
            
            // button to link users to settings
            if showWarning{
                Text ("Notifications are disabled")
                    .font(.appBody())
                Button ("Enable"){
                    //open settings using app url in settings
                    DispatchQueue.main.async {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options:[:], completionHandler: nil)
                    }
                }
                .font(.appBody())
            }
            else{
                Text ("Notifications are enabled :)")
                    .font(.appBody())
            }
            
            Button ("send test notification"){
                BindTimerNotification.scheduleNotification(identifier: "my-notification", seconds: 5, title: "Test notification", body: "Some message")
            }
            .buttonStyle(.borderedProminent)
            .font(.appBody())
            // this is to help user allow notifications, through a enable button that leads to settings
            Spacer()
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
#Preview{
    NotificationControlView()
}
