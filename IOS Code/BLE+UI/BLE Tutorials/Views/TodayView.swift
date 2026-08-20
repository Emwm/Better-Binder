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
import SwiftData


// helper function to change gauge color between two asset colors
private func _colorForProgress(_ p: Double,
                               startColor: Color = Color("colorLightBlue"),
                               endColor: Color = Color("colorDarkBlue")) -> Color {
    // Clamp t to [0, 1]
    let t = max(0.0, min(1.0, p))

    // Extract RGBA components from SwiftUI Color using UIColor/NSColor
    #if canImport(UIKit)
    func rgba(from color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }
    #elseif canImport(AppKit)
    func rgba(from color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let nsColor = NSColor(color)
        let converted = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        return (Double(converted.redComponent),
                Double(converted.greenComponent),
                Double(converted.blueComponent),
                Double(converted.alphaComponent))
    }
    #else
    func rgba(from color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        return (1,1,1,1)
    }
    #endif

    let s = rgba(from: startColor)
    let e = rgba(from: endColor)

    // Linear interpolation for each channel
    let r = s.r + (e.r - s.r) * t
    let g = s.g + (e.g - s.g) * t
    let b = s.b + (e.b - s.b) * t
    let a = s.a + (e.a - s.a) * t

    return Color(red: r, green: g, blue: b).opacity(a)
}

struct TodayView: View {
    @Environment(BindManager.self) private var bsm
    @Environment(BindTimer.self) private var timer
    
    //changable var for timer button
    @State private var buttonState = false
    
    //state vars for information pop ups (so they act as buttons)
    @State private var showTotalTimeTodayInfo = false
    @State private var showTimerInfo = false
    @State private var showPreviousSessionsInfo = false
    
    
    @Query private var todaySessions: [BindSession]

    init() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        // The Predicate acts like a SQL "WHERE" clause
        let filter = #Predicate<BindSession> { session in
            session.startDate >= startOfToday && session.startDate < endOfToday
        }

        // Initialize the query with the filter
        _todaySessions = Query(filter: filter, sort: \.startDate, order: .reverse)
    }
    
    private func deleteSession(at offsets: IndexSet, from filteredList: [BindSession]) {
        for index in offsets {
            // Find the specific session in the filtered list
            let sessionToDelete = filteredList[index]
            
            // Delete it from the persistent store by calling delete function in bind timer
            timer.deleteBindSession(sessionToDelete)
        }
    }
    
    var body: some View {
        ScrollView{
            VStack{
                
                // Header Text Section ---------------------------
                HStack{
                    Image("logo_solidFill_blue")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text("Today") // list view of each bind today
                        .font(.appHeader())
                        .foregroundColor(.colorDarkBlue)
                    
                    // Info button using InfoButton helper file
                    InfoButton(title: "Today Page Help", tint: .colorDarkBlue) {
                        VStack {
                            Text("Page Overview:")
                                .font(.appBodyBold())
                            Text("Track the time you spend binding today by using the start and stop timer button. You will recieve notifications when you have reached your time limit.")
                                .font(.appBody())
                                .mediumPaddingBottom()
                        
                            Text("On this page see your:")
                                .font(.appBodyBold())
                                .smallPaddingBottom()
                            // manual list
                            VStack(alignment: .leading) {
                                Label("Total time binding today", systemImage: "1.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Label("Visually how close you are to reaching your binding limit", systemImage: "2.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Label("All of the binding sessions you have completed today", systemImage: "3.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .font(.appSmallCaption())
                            .mediumPaddingBottom()
                            
                            Text("Tips:")
                                .font(.appBodyBold())
                                .smallPaddingBottom()
                            // manual list
                            VStack(alignment: .leading) {
                                Label("Swipe left on an entry in previous sessions to delete it", systemImage: "1.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Label("Change your binding limit in settings", systemImage: "2.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .font(.appSmallCaption())
                            .mediumPaddingBottom()
                        }
                    }
                }
                .largePaddingTop()
                
                Text(Date.now.formatted(date: .long, time: .omitted))
                    .font(.appSubHeader())
                    .foregroundColor(.colorDarkBlue)
                    .mediumPaddingBottom()
                
                // Total Time Today Section -----------------------------
                Text("Total Time Today:")
                    .font(.appBodyBold())
                    .smallPaddingBottom()
                Text("\(timer.secondsPassedTodayString)") // total time today
                    .font(.appBody())
                    .smallPaddingBottom()
                
                // Guage
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
                    Text("\(Double( timer.secondsBindLimit/(60*60) ).formatted(.number.precision(.fractionLength(1)))) hrs")
                        .font(.appSmallCaption())
                }
                .padding(.horizontal)
                .mediumPaddingBottom()
                
                // Timer Section ----------------------
                ZStack{
                    // Background rectangle
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.colorLightBlue))
                    
                    VStack{
                        // Button
                        Button(action: {
                            if timer.state == .idle {
                                timer.start()
                            } else{
                                timer.stop()
                            }
                            
                            buttonState.toggle()
                        }) {
                            Text(buttonState ? "Stop Timer" : "Start Timer")
                                .font(.appBodyBold())
                                
                        }.buttonStyle(.borderedProminent)
                            .tint(buttonState ? .accent : .colorDarkBlue)
                            .mediumPaddingBottom()
                            .largePaddingTop()
                        
                        // Current timer time
                        Text("Current Session Time:")
                            .font(.appBody())
                        if timer.state == .running {
                            Text("\(timer.secondsPassedThisBind.asTimestamp())")
                                .font(.appBody())
                                .largePaddingBottom()
                        } else{
                            Text("00:00:00")
                                .font(.appBody())
                                .largePaddingBottom()
                        }
                    }
                }
                . mediumPaddingBottom()
                .padding(.horizontal, 20)
                
                // List of Todays Binding History Section --------------------
                Text("Previous Sessions:")
                    .font(.appBodyBold())
                    .smallPaddingBottom()
                
                if todaySessions.isEmpty {
                    Text("No history yet.")
                        .font(.appBody())
                } else {
                    List{
                        ForEach(todaySessions) { todayList in
                            HStack{
                                VStack(alignment: .leading){
                                    Text("Start Time:")
                                        .font(.appBody())
                                    Text("\(todayList.startDate.formatted(date: .omitted, time: .shortened))")
                                        .font(.appBody())
                                }
                                
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.colorDarkBlue)
                                    .frame(width: 2)
                                    .frame(height: 32)
                                    .padding(.horizontal, 8)
                                
                                VStack(alignment: .leading){
                                    Text("Duration:")
                                        .font(.appBody())
                                    Text("\(todayList.durationSeconds.asTimestamp())")
                                        .font(.appBody())
                                }
                            }
                        }
                        .onDelete { indexSet in
                            deleteSession(at: indexSet, from: todaySessions)
                        }
                        
                    }
                    .listStyle(.insetGrouped) // or .plain, .grouped, etc.
                    .frame(height: 300)  // choose a height that fits your design
                }
                Spacer()
            }
        }
    }
}

#Preview {
    // 1. Create an in-memory container (clears every time the preview restarts)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, configurations: config)
    
    // 3. Initialize the manager with the mock context
    let mockManager = BindTimer(modelContext: container.mainContext)
    
    TodayView()
        .environment(BindManager())
        .environment(mockManager)
        .modelContainer(container)
}
