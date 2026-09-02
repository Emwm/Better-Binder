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
    
    @State private var yearOffset: Int = 0 //needed for prev year
    @State private var gridData: [[Color]] = Array(
        repeating: Array(repeating: Color.gray.opacity(0.2), count: 31),
        count: 12
    )
    
    //changes first date to subtract year offset
    private var referenceDate: Date {
        Calendar.current.date(byAdding: .year, value: yearOffset, to: Date()) ?? Date()
    }
    
    //creating a dynamic variable that puts the current month first, making display easier
    private var trailingMonths: [Date] {
        let cal = Calendar.current
        return (0..<12).reversed().compactMap { offset in cal.date(byAdding: .month, value: -offset, to: referenceDate)
        }
    }
    //func for year text that can change
    private var titleText: String {
        guard let first = trailingMonths.first, let last = trailingMonths.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyy"
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20){
                Button(action: {yearOffset -= 1}) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                Text(titleText)
                    .font(.appBodyBold())
                    .foregroundStyle(.white)
                
                Button(action: {yearOffset += 1}) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                // no clicking into the future
                    .disabled(yearOffset >= 0)
                    .opacity(yearOffset >= 0 ? 0.3 : 1.0)
            }
            /*.padding(.top, 5)
            .padding(.bottom, 5)*/
            
            .padding(.vertical, 10)
            .padding(.horizontal, 20)

            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.colorCoral.opacity(1))
            )
            /*
            .frame(maxWidth: .infinity)
            .background(Color.colorCoral.opacity(0.5))
            */
            //code to add a coloured background behind the date, might remove or repurpose bc it kinda looks weird, would be better with a square?


            
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
                HStack(alignment: .top, spacing: 3){
                    ForEach(0..<12, id: \.self) { monthIndex in
                        VStack(spacing: 3) {
                            
                            //Month label
                            Text(trailingMonths[monthIndex].formatted(.dateTime.month(.abbreviated)))
                                .font(.appYearView())
                                .foregroundColor(.secondary)
                            
                            ForEach(0..<31, id: \.self) { dayIndex in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(gridData[monthIndex][dayIndex])
                                    .frame(width:14, height:14)
                                
                            }
                            
                        }

                    }
                }
                .containerRelativeFrame(.horizontal)
                .onAppear(){
                    dataFill()
                }
                .onChange(of: yearOffset) { _, _ in
                    dataFill()
                }
            }
            
            Spacer()
        }

    }
    
    private func dataFill() {
        let cal = Calendar.current
        guard let currentMonthStart = cal.date(from: cal.dateComponents([.year, .month], from: referenceDate)) else { return }
        
        //grid with preset defaults in case real data doesn't exist
        var tempGrid = Array(repeating: Array(repeating: Color.gray.opacity(0.2), count: 31), count: 12)
        let limit = timer.secondsBindLimit //self explanatory, from timer manager
        
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
