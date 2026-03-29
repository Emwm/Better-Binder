//
//  CalibrationView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-28.
//

import SwiftUI
struct CalibrationView: View {
    @AppStorage("minCompression") private var minPoint: Double = 50
    @AppStorage("maxCompression") private var maxPoint: Double = 3500
    @Environment(BLEManager.self) private var ble
    
    var body: some View {
        
        let currentStatus = Double(ble.statusInt)
        let compValue = DynPos(for: currentStatus)

        VStack{
                    Text("Compression Calibration")
                        .font(.title)
                        .padding(.bottom, 15)
                        .bold()
            
                    // gauge visual --------------------------
                    Gauge(value: compValue+0.1, in: 0...1.2){
                        Text("Compression State:")
                            .padding(.bottom, 5)
                            .font(.system(size: 25))
                            .bold()
                        Text("Percentage Compressed:")
                            .font(.system(size: 20))
                        Text("\(Double(compValue)*100)%")
                            .font(.system(size: 20))
                            .padding(.bottom, 10)
                    } currentValueLabel: {
                        VStack{
                            HStack{
                                Text("Min: \(Int(minPoint))")
                                    .font(.system(size: 20))
                                Spacer()
                                Text("Max: \(Int(maxPoint))")
                                    .font(.system(size: 20))
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    //tint(fillColor(for: currentStatus))
                    .gaugeStyle(.linearCapacity) // Or .accessoryCircular
                    .animation(.spring(), value: currentStatus)
                    .padding()
                
                    // setting values visual -----------------------
                    ZStack{
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemGray5))
                            .frame(width: 350, height: 140) // minimum size
                        VStack{
                            // setting max and min values ------------------
                            Text("Current Compression Value:")
                                .font(.system(size: 20))
                            Text("\(Int(currentStatus))")
                                .padding(.bottom, 5)
                                .font(.system(size: 25))
                                .bold()
                            HStack{
                                Text("Set as:")
                                    .padding(.bottom, 5)
                                    .font(.system(size: 20))
                                Button("Min Value"){
                                    minPoint = currentStatus
                                }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .padding(.horizontal, 5)
                                    .bold()
                                    
                                
                                Button("Max Value"){
                                    maxPoint = currentStatus
                                }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .padding(.horizontal, 5)
                                    .bold()
                            }
                        }
                    }
                }
                Spacer()
    }
    
    private func DynPos(for value: Double) -> Double {
            let span = maxPoint - minPoint
            
            // Prevent division by zero if min and max are the same
            guard span != 0 else { return 0 }
            
            // Calculate percentage: (Current - Min) / Span
            let percentage = (value - minPoint) / span
            
            // Clamp it between 0 and 1 so the bar doesn't break the UI
            let clampedPercentage = max(0, min(percentage, 1.0))
            
            return clampedPercentage
        }
    
    private func fillColor(for value: Double) -> Color {
            if value < minPoint { return .orange }
            if value > maxPoint { return .red }
            return .green // Within the "Set" compression range
        }
}
struct MarkerIndicator: View {
    var label: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 10, weight: .bold))
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 24)
        }
        .foregroundColor(color)
    }
    
    
}


#Preview {
    CalibrationView()
        .environment(BLEManager.mock)
}
