//
//  SwiftUIView.swift
//  BLE Tutorials
//
//  Created by Kent and Lia Morley on 2026-08-20.
//

import SwiftUI
import SwiftData

struct YearView: View {
    
    @Query var historicalDays: [DailyTotal]
    
    @Environment(BindTimer.self) private var timer
    
    @State private var gridData: [[Color]] = Array(
        repeating: Array(repeating: Color.gray.opacity(0.2), count: 31),
        count: 12
    )
    
    //creating a dynamic variable that puts the current month first, making display easier
    private var trailingMonths: [Date] {
        let cal = Calendar.current
        let today = Date()
        return (0..<12).reversed().compactMap { offset in cal.date(byAdding: .month, value: -offset, to: today)
        }
    }
    
    var body: some View {
        VStack {
            
//            // Top Header Section ---------------------------------
//            HStack{
//                Image("logo_solidOutline_coral")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 50, height: 50)
//                Text("Yearly Trend") // list view of each bind today
//                    .font(.appHeader())
//                    .foregroundStyle(Color.colorDarkCoral)
//            }
//            .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 4){
                    ForEach(0..<12, id: \.self) { monthIndex in
                        VStack(spacing: 3) {
                            
                            //Month label
                            Text(trailingMonths[monthIndex].formatted(.dateTime.month(.abbreviated)))
                                .font(.appYearView())
                                .foregroundColor(.secondary)
                            
                            ForEach(0..<31, id: \.self) { dayIndex in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(gridData[monthIndex][dayIndex])
                                    .frame(width:15, height:15)
                                
                            }
                            
                        }
                        
                        
                        
                    }
                }
                .containerRelativeFrame(.horizontal)
                .onAppear(){
                    dataFill()
                }
            }
            
            Spacer() // pushes ui to top
        }

    }
    
    private func dataFill() {
        let cal = Calendar.current
        let today = Date()
        guard let currentMonthStart = cal.date(from: cal.dateComponents([.year, .month], from: today)) else { return }
        
        //grid with preset defaults in case real data doesn't exist
        var tempGrid = Array(repeating: Array(repeating: Color.gray.opacity(0.2), count: 31), count: 12)
        var limit = timer.secondsBindLimit //self explanatory, from timer manager
        
        for entry in historicalDays {
            let entryDate = entry.day
            guard let entryMonthStart = cal.date(from: cal.dateComponents([.year, .month], from: entryDate)) else {continue}
            
            //month difference for determining column
            let monthDiff = cal.dateComponents([.month], from: entryMonthStart, to: currentMonthStart).month ?? 0
            //column correction
            let colIndex = 11 - monthDiff
            if colIndex >= 0 && colIndex < 12 {
                //isolate day of the month for placing on chart
                let dayOfMonth = cal.component(.day, from:entryDate)
                let rowIndex = dayOfMonth - 1 //fixing array zero start
                
                //if statement to limit only 12 months
                if rowIndex >= 0 && rowIndex < 31 {
                    let total = Double(entry.totalSeconds) //intifying the seconds
                    
                    if total >= limit {
                        tempGrid[colIndex][rowIndex] = .colorCoral
                    } else if total > 0 {
                        tempGrid[colIndex][rowIndex] = .colorLightCoral
                    }
                }
                
            }
            gridData = tempGrid
        }
    }
}

#Preview {
    // 1. Create an in-memory container (clears every time the preview restarts)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, DailyTotal.self, configurations: config)
    
    // 3. Initialize the manager with the mock context
    let mockManager = BindTimer(modelContext: container.mainContext)
    
    YearView()
        .environment(BindManager())
        .environment(mockManager)
        .modelContainer(container)
}
