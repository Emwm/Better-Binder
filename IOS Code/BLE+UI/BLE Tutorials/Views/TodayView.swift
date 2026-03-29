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

// helper function to change gauge color from green to blue
private func _colorForProgress(_ p: Double) -> Color {
    // Clamp to [0, 1]
    let t = max(0, min(1, p))
    // Interpolate from green (0,1,0) to blue (0,0,1)
    let r = 0.0
    let g = 1 - t - 0.3 // the 0.3 is to start at a darker color
    let b = t - 0.3
    return Color(red: r, green: g, blue: b)
}

struct TodayView: View {
    // state properties here -----------------------------------
    
    @Environment(\.bindTimer) private var timer
    // public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
    
    var body: some View {
        VStack{

            // Top today text ---------------------------
            Text("Today") // list view of each bind today
                .font(.title)
                .bold()
                .padding(.top, 10)
            
            Text(Date.now.formatted(date: .long, time: .omitted))
                .font(.system(size: 25))
                .padding(.bottom,20)
            
            // Time binded ---------------------------------
            Text("Time Binded:")
                .font(.system(size: 25))
                .bold()
                .padding(.bottom, 5)
            Text("\(timer.secondsPassedTodayString)") // total time today
                .font(.system(size: 25))
                .padding(.bottom, 5)
            
            // Gauge of fraction passed ------------------------
            Gauge(value: timer.fractionPassedToday, in: 0...1) {
            } currentValueLabel: {
            }
            .gaugeStyle(.linearCapacity)
            .tint(_colorForProgress(timer.fractionPassedToday))
            .padding(.horizontal, 20)
            .frame(height: 30) // increase this to make it thicker
            // 8 hour limit lable by gauge
            HStack{
                Text("0 hrs")
                    .font(.system(size: 20))
                Spacer()
                Text("8 hrs")
                    .font(.system(size: 20))
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // List View ----------------------------
            Text("List of Binds Today:") // list view of each bind today
                .font(.system(size: 25))
                .padding(.bottom, 5)
            
            List{
                ForEach(timer.bindSessionHistory.filter { Calendar.current.isDateInToday($0.startDate) }) { todayList in
                    HStack{
                        VStack(alignment: .leading){
                            Text("\(todayList.startDate.formatted(date: .abbreviated, time: .omitted))")
                            Text("\(todayList.startDate.formatted(date: .omitted, time: .shortened))")
                                
                        }
                        Spacer()
                        Text("Duration: \(_formatSeconds(todayList.durationSeconds))")
                    }
                }
            }
            
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
}
#Preview {
    TodayView()
}
