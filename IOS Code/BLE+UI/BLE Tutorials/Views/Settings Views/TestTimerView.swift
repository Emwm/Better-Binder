//
//  TestTimerView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/28/26.
//

import SwiftUI
import SwiftData

struct TestTimerView: View {
    @Environment(BindTimer.self) private var timer
    
    @State private var newTimeLimit = 0.0
    
    var body: some View {
        // Timer Block ----------------------------
        VStack{
            Text("Manual Timer")
                .font(.appSubHeader())
            Text("for the today page")
                .font(.appBody())
                .largePaddingBottom()
            ZStack{
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray5))
                    .frame(width: 350, height: 160) // minimum size
                
                VStack(spacing: 5){
                    // temporary timer via buttons for testing
                    Text("Time of this Bind:")
                        .font(.appBodyBold())
                    Text("\(timer.secondsPassedThisBind)") // time of this bind running here
                        .font(.appBody())
                        .mediumPaddingBottom()
                    if timer.state == .idle{
                        Button("START"){
                            timer.start()
                        }
                            .buttonStyle(.borderedProminent)
                            .font(.appBody())
                    }
                    if timer.state == .running{
                        Button("STOP"){
                            timer.stop()
                        }
                            .buttonStyle(.borderedProminent)
                            .font(.appBody())
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        
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
    // 1. Create an in-memory container (clears every time the preview restarts)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, configurations: config)
    
    // 3. Initialize the manager with the mock context
    let mockManager = BindTimer(modelContext: container.mainContext)
    
    TestTimerView()
        .environment(mockManager)
}
