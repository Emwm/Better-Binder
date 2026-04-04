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
    
    @Environment(BindManager.self) private var bsm
    @Environment(\.bindTimer) private var timer
    
    var body: some View {
        VStack{

            // Top today text ---------------------------
            HStack{
                Image("logo_threeColor")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("Today") // list view of each bind today
                    .font(.appHeader())
            }
            .largePaddingTop()
            
            Text(Date.now.formatted(date: .long, time: .omitted))
                .font(.appSubHeader())
                .largePaddingBottom()
            
            // Time today of binding ---------------------------------
            Text("Total Binding Time:")
                .font(.appBodyBold())
                .smallPaddingBottom()
            Text("\(timer.secondsPassedTodayString)") // total time today
                .font(.appBody())
                .smallPaddingBottom()
            
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
                    .font(.appSmallCaption())
                Spacer()
                Text("8 hrs")
                    .font(.appSmallCaption())
            }
            .padding(.horizontal)
            .largePaddingBottom()
            
            // Current binding state --------------------
            HStack{
                Text("Current Compression State:")
                    .font(.appBody())
                Text("\(String(describing: bsm.currentState))")
                    .font(.appBody())
            }
                .largePaddingBottom()
            
            // List View of today binding history ----------------------------
            Text("List of Bind Sessions:") // list view of each bind today
                .font(.appBody())
                .smallPaddingBottom()
            
            List{
                ForEach(timer.bindSessionHistory.filter { Calendar.current.isDateInToday($0.startDate) }) { todayList in
                    HStack{
                        VStack(alignment: .leading){
                            Text("\(todayList.startDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.appBody())
                            Text("\(todayList.startDate.formatted(date: .omitted, time: .shortened))")
                                .font(.appBody())
                                
                        }
                        Spacer()
                        Text("Duration: \(todayList.durationSeconds.asTimestamp())")
                            .font(.appBody())
                    }
                }
            }
            .listStyle(.insetGrouped) // or .plain, .grouped, etc.
            .frame(height: 300)       // choose a height that fits your design
            
            Spacer()
            
//            // Testing Block ----------------------------
//            ZStack{
//                RoundedRectangle(cornerRadius: 14)
//                    .fill(Color(.systemGray5))
//                    .frame(width: 350, height: 140) // minimum size
//                
//                VStack(spacing: 5){
//                    // temporary timer via buttons for testing
//                    Text("Temporary For Timer Testing")
//                        .font(.system(size: 20))
//                        .bold()
//                    Text("Time of this Bind:")
//                        .font(.system(size: 20))
//                    Text("\(timer.secondsPassedThisBind)") // time of this bind running here
//                        .font(.system(size: 20))
//                    if timer.state == .idle{
//                        Button("START"){
//                            timer.start()
//                        }
//                            .buttonStyle(.borderedProminent)
//                    }
//                    if timer.state == .running{
//                        Button("STOP"){
//                            timer.stop()
//                        }
//                            .buttonStyle(.borderedProminent)
//                    }
//                }
//            }
//            .padding(.horizontal)
        }
    }
}
#Preview {
    TodayView()
        .environment(BindManager())
}
