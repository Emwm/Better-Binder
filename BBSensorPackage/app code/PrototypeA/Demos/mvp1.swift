//
//  mvp1.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/10/26.
//

/*
 the goal of this file is to create a minimum viable prototype (mvp) that has timer functionality and ui
 functionality: time binded today (with visual graphic of fraction of time passed/time limit, totaled time value, and list view of binds for that day)
                previous binds (list of all previous binds not including todays date)
 */

import SwiftUI

struct mvp1: View {
    // state properties here -----------------------------------
    
    // create instance of timer
    @State private var timer: BindTimer = BindTimer()
    // public varaibles for BindTimer -> secondsPassed, secondsPassedString, secondsLeft, secondsLeftString, fractionPassed, fractionLeft, BindTimerState
    // access public variables via timer.secondsPassed
    // the @State means mvp1 owns this timer and only one timer is created in this view, could change later if need to change what owns this timer
    
    var body: some View {
        VStack{
            // Time Binded Today ----------------------------
            Text("Time Binded Today")
                .bold()
                .font(.system(size: 20))
            // TO ADD HERE visual view of fraction passed
            Text("00:00") // total time today
                .padding(.bottom, 10)
            
            // temporary timer via buttons for testing
            Text("Temporary For Timer Testing")
            Text("This Bind:")
            Text("00:00") // time of this bind running here
            if timer.state == .idle{
                Button("start"){
                    timer.start()
                }
            }
            if timer.state == .running{
                Button("stop"){
                    timer.stop()
                }
            }
            
            Text("Binds Today") // list view of each bind today
            // TO ADD HERE list view of binds for the day
                .padding(.top, 10)
            
            // History of Previous Binds ----------------------------
            Text("History of Binds") // list view of each bind today
                .bold()
                .font(.system(size: 20))
                .padding(.top, 10)
            // TO ADD HERE list view of binds for the day
        }
    }
}
#Preview {
    mvp1()
}

