//
//  CalibrationView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-28.
//

import SwiftUI
struct CalibrationView: View {
    @Environment(BindManager.self) private var bsm
    
    var body: some View {
        
        let currentStatus = Double(bsm.rawInt)
        let compValue = Double(bsm.perCompression)
        let minPoint = Double(bsm.minValue)
        let maxPoint = Double(bsm.maxValue)

        VStack{
                    Text("Compression Calibration")
                        .font(.title)
                        .padding(.bottom, 10)
                        .bold()
            
                    // gauge visual --------------------------
            Gauge(value: compValue+0.1, in: 0...1.2){
                        Text("Compression State:")
                            .padding(.bottom, 5)
                            .font(.system(size: 25))
                            .bold()
                        Text("Percentage Compressed:")
                            .font(.system(size: 20))
                        
                        //String(format: "%02d:%02d.%02ds", hh, mm, ss)
                        Text("\(Decimal(compValue*100).formatted(.number.precision(.fractionLength(0))))%")
                            .font(.system(size: 20))
                            .padding(.bottom, 10)
                            .bold()
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
                    .tint(fillColor(for: currentStatus))
                    .gaugeStyle(.linearCapacity) // Or .accessoryCircular
                    .animation(.spring(), value: currentStatus)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                
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
                                .font(.system(size: 20))
                                .bold()
                            HStack{
                                Text("Set as:")
                                    .padding(.bottom, 5)
                                    .font(.system(size: 20))
                                Button("Min Value"){
                                    bsm.minChange(for: currentStatus)
                                }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .padding(.horizontal, 5)
                                    .bold()
                                    
                                
                                Button("Max Value"){
                                    bsm.maxChange(for: currentStatus)
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
    
    
    private func fillColor(for value: Double) -> Color {
        if value < 0.9 { return .orange }
        if value > 0.1 { return .red }
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
        .environment(BindManager())
}
