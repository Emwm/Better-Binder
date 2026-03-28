//
//  TimerDemo.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/2/26.
//

/*
 UI to test just notification logic in BinderTimer code
 */


import SwiftUI

struct TimerDemo: View {
    // create instance of timer
    private var timer: BindTimer = BindTimer()
    
    var body: some View {
        Text("Total Bind Time Today: \(timer.secondsPassedTodayString)")
        Text("Fraction Passed Today: \(timer.fractionPassedToday)")
            .padding(.bottom, 5)
        Text("Bind Time Passed This Session: \(timer.secondsPassedThisBind)")
        Text("Timer State: \(timer.state.rawValue)")
        
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
    }
}
#Preview {
    TimerDemo()
}
