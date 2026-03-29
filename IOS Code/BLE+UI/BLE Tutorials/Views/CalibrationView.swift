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

        VStack(spacing:30){
            Text("Compression Calibration")
                .font(.headline)
            Gauge(value: compValue, in: 0...1){
                Text("Value")
            } currentValueLabel: {
                VStack{
                    Text("Curent Value is \(Int(currentStatus))")
                    Text("Computed Value is \(Double(compValue)*100)%")
                    Text("Raw Int: \(ble.statusInt)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    
                    
                }
            }
            //tint(fillColor(for: currentStatus))
            .gaugeStyle(.linearCapacity) // Or .accessoryCircular
            .animation(.spring(), value: currentStatus)
            .padding()
        }
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
        .environment(BLEManager())
}
