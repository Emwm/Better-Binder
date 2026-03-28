//
//  HistoryView.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/19/26.
//

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

struct HistoryView: View {
    @Environment(\.bindTimer) private var timer
    // public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
    
    var body: some View {
        VStack{
            Text("Total History of Binds:") // list view of each bind today
                .font(.system(size: 20))
                .bold()
                .padding(.top, 10)
            
            List{
                ForEach(timer.bindSessionHistory){ historyList in
                    HStack{
                        Text("\(historyList.startDate.formatted()),")
                        Text("Duration: \(_formatSeconds(historyList.durationSeconds))")
                    }
                }
            }
        }
    }
}
#Preview { // this is for formatting
    let previewTimer = BindTimer() // or whatever your type is
    previewTimer.seedFakeHistory(days: 10, sessionsPerDay: 3, durationRange: 300...3600)

    return HistoryView()
        .environment(\.bindTimer, previewTimer)
}
