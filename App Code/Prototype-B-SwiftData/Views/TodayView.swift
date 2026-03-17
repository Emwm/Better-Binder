//
//  TodayView.swift
//  Prototype-B-SwiftData
//
//  Created by Reese Brogden on 3/16/26.
//

/*
 the goal of this file is to create a minimum viable prototype (mvp) that has timer functionality and ui
 functionality: time binded today (with visual graphic of fraction of time passed/time limit, totaled time value, and list view of binds for that day)
                previous binds (list of all previous binds not including todays date)
 
public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindTimerState, secondsPassedThisBind

 access public variables like timer.secondsPassedToday

 the @State means mvp1 owns this timer and only one timer is created in this view, could change later if need to change what owns this timer
 
 */

import SwiftUI
import Foundation
import SwiftData

struct TodayView: View {
    @State private var timer: BindTimer = BindTimer(modelContext: )
    @State private var sessions: [BindSessionModel] = []
    
    var body: some View {
        // lazy initialization (initialized the first time the view renders)
        
        VStack{
            // Time Binded Today ----------------------------
            Text("Time Binding Today")
                .bold()
                .font(.system(size: 35))
            
            Text("\(timer.secondsPassedTodayString)") // total time today
                .font(.system(size: 30))
                .padding(.bottom, 10)
            
            // visual for fraction passed
            Gauge(value: timer.fractionPassedToday, in: 0...1) {
            } currentValueLabel: {
                Text("\(Int(timer.fractionPassedToday * 100))%")
                    .font(.system(size: 25))
            }
            .gaugeStyle(.accessoryLinear)
            .tint(.purple)
            .padding(.horizontal)
            
            HStack{
                Spacer()
                Text("8 hrs")
                    .font(.system(size: 20))
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
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
            
            Text("List of Binds Today:") // list view of each bind today
                .font(.system(size: 20))
                .bold()
                .padding(.top, 10)
            
            // list of times
            
            List {
                ForEach(sessions) { session in
                    VStack(alignment: .leading) {
                        Text(session.startDate.formatted())
                        Text("\(session.durationSeconds) seconds")
                    }
                }
            }
            
//            // History of Previous Binds ----------------------------
//            Text("History of Binds") // list view of each bind today
//                .bold()
//                .font(.system(size: 25))
//                .padding(.top, 10)
//            // TO ADD HERE list view of binds for the day
        }
    }
}
