//
//  UIDemo1.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/2/26.
//

/*
 Initial rough UI prototype to try out list view and timer UI
 
 Started to follow this tutorial:
 https://www.youtube.com/watch?v=ayn9CdqbI_Y&t=2695s
 */

import SwiftUI
import Foundation

// data model for our tasks
struct TimeTask: Identifiable { // identifiable lets track individual tasks in things like lists
    let id = UUID() // unique identifier for every task
    var lengthTime: String
    var dateManual: String = "3/1/26"
    var isTodayDate: Bool = true
}

struct UIDemo1: View {
    // declare our state variables here
    @State private var todayDateManual: String = "3/1/26"
    @State private var timeCount: Int=0
    @State private var timesList: [TimeTask] = [
        TimeTask(lengthTime: "10"),
        TimeTask(lengthTime: "20"),
        TimeTask(lengthTime: "98", dateManual: "2/26/26", isTodayDate: false)
    ]
    @State private var newTimeLength = ""
    @State private var newTimeDate: String = ""
    
    var body: some View {
        VStack {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 50)) //can scale system symbols like they are text
            
            Text("Daily Binding Time:")
                .font(.system(size: 30))
            
            Text("\(timeCount)")
                .font(.system(size: 45))
                .padding(5)
            
            HStack{
                
                Button("START"){
                    // action that happens with button press
                }
                .buttonStyle(.borderedProminent)
                .padding(5)
                
                Button("STOP"){
                    // action that happens with button press
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 10)
            
            // add a new time area
            HStack{
                TextField("New Time", text: $newTimeLength)
                    .textFieldStyle(.roundedBorder)
                TextField("Date 1/10/26", text: $newTimeDate)
                    .textFieldStyle(.roundedBorder)
                Button("ADD"){
                    addTime()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTimeLength.isEmpty) // wont add to list if empty
                .disabled(newTimeDate.isEmpty)
            }
        }
        .padding()
        
        // list of times
        List{
            ForEach(timesList){ timesList in
                HStack{
                    Image(systemName: timesList.isTodayDate ? "checkmark.circle.fill" : "xmark.circle") // changes image basaed on boolean state
                    Text("\(timesList.dateManual):")
                    Text("\(timesList.lengthTime) minutes")
                }
            }
        }
    }
    
    // function to take input in entries and add them to list of times
    private func addTime() {
        var newTime = TimeTask(lengthTime: newTimeLength, dateManual: newTimeDate)
        // Evaluate today's date flag before/after inserting
        if newTime.dateManual == todayDateManual {
            newTime.isTodayDate = true
        } else {
            newTime.isTodayDate = false
        }
        timesList.append(newTime)
        // resets entry boxes to blank
        newTimeLength = ""
        newTimeDate = ""
    }
}
