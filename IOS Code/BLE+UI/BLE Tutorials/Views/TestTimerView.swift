//
//  TestTimerView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/28/26.
//

import SwiftUI

struct TestTimerView: View {
    @Environment(\.bindTimer) private var timer
    // public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
    
    var body: some View {
        // Testing Block ----------------------------
        ZStack{
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray5))
                .frame(width: 350, height: 140) // minimum size
            
            VStack(spacing: 5){
                // temporary timer via buttons for testing
                Text("Temporary For Timer Testing")
                    .font(.system(size: 20))
                    .bold()
                Text("Time of this Bind:")
                    .font(.system(size: 20))
                Text("\(timer.secondsPassedThisBind)") // time of this bind running here
                    .font(.system(size: 20))
                if timer.state == .idle{
                    Button("START"){
                        timer.start()
                    }
                        .buttonStyle(.borderedProminent)
                }
                if timer.state == .running{
                    Button("STOP"){
                        timer.stop()
                    }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.horizontal)
    }
}
