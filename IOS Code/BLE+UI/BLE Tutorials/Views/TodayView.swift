//
//  TodayView.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/19/26.
//

/*
 functionality: time binded today (with visual graphic of fraction of time passed/time limit, totaled time value, and list view of binds for that day)
                previous binds (list of all previous binds not including todays date)
 */

import SwiftUI
import Foundation

// formats our seconds variables into hh, mm, ss
private func _formatSeconds(_ seconds:Int) -> String {
    if seconds <= 0 {
        return "00:00:00"
    }
    let hh: Int = seconds / 3600
    let mm: Int = (seconds % 3600) / 60
    let ss: Int = seconds % 60
    return String(format: "\(hh):\(mm).\(ss)s")
}

struct TodayView: View {
    // state properties here -----------------------------------
    
    @Environment(\.bindTimer) private var timer
    // public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
    
    var body: some View {
        VStack{

            // Top today text ---------------------------
            Text("Today")
                .bold()
                .font(.system(size: 40))
            
            Text(Date.now.formatted(date: .long, time: .omitted))
                .font(.system(size: 25))
                .padding(.bottom,2)
            
            // Time binded ---------------------------------
            Text("Time Binded")
                .font(.system(size: 25))
            Text("\(timer.secondsPassedTodayString)") // total time today
                .font(.system(size: 25))
                .padding(.bottom, 10)
            
            // Gauge of fraction passed ------------------------
            Gauge(value: timer.fractionPassedToday, in: 0...1) {
            } currentValueLabel: {
                Text("\(Int(timer.fractionPassedToday * 100))%")
                    .font(.system(size: 25))
            }
            .gaugeStyle(.accessoryLinear)
            .tint(.green)
            .padding(.horizontal)
            // 8 hour limit lable by gauge
            HStack{
                Spacer()
                Text("8 hrs")
                    .font(.system(size: 20))
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
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
            
            // List View ----------------------------
            Text("List of Binds Today:") // list view of each bind today
                .font(.system(size: 20))
                .padding(.top, 15)
                .padding(.bottom, 10)
            
            List{
                ForEach(timer.bindSessionHistory.filter { Calendar.current.isDateInToday($0.startDate) }) { todayList in
                    HStack{
                        Text("\(todayList.startDate.formatted()),")
                        Text("Duration: \(_formatSeconds(todayList.durationSeconds))")
                    }
                }
            }
        }
    }
}
#Preview {
    TodayView()
}
