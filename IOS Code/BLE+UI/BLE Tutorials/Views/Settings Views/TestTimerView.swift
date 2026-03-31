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
    
    @State private var newTimeLimit = 0.0
    
    var body: some View {
        // Timer Block ----------------------------
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
        
//        // Set new Timer Limit
//        ZStack{
//            RoundedRectangle(cornerRadius: 14)
//                .fill(Color(.systemGray5))
//                .frame(width: 350, height: 140) // minimum size
//            
//            VStack(spacing: 5){
//                // temporary timer via buttons for testing
//                Text("Set New Binding Limit")
//                    .font(.system(size: 20))
//                    .bold()
//                HStack{
//                    TextField("Enter minutes", value: $newTimeLimit, format: .number)
//                    Button("ADD"){
//                        timer.setDailyBindLimit(seconds: newTimeLimit)
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//                
//            }
//        }
//        .padding(.horizontal)
    }
}
#Preview {
    TestTimerView()
        .environment(BindManager())
}
