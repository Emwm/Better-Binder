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
            Text("Compression")
                .font(.appHeader())
                .largePaddingTop()
            Text("Calibration")
                .font(.appHeader())
                .largePaddingBottom()
        
            Text("Current Compression State:")
                .font(.appBody())
            Text("\(String(describing: bsm.currentState))")
                .font(.appBodyBold())
                .mediumPaddingBottom()
            
            // gauge visual --------------------------
            Gauge(value: compValue+0.1, in: 0...1.2){
                        Text("Percentage Compressed:")
                            .font(.appBody())
                        
                        //String(format: "%02d:%02d.%02ds", hh, mm, ss)
                        Text("\(Decimal(compValue*100).formatted(.number.precision(.fractionLength(0))))%")
                            .font(.appBodyBold())
                            .mediumPaddingBottom()
                    } currentValueLabel: {
                        VStack{
                            HStack{
                                Text("Min: \(Int(minPoint))")
                                    .font(.appBody())
                                Spacer()
                                Text("Max: \(Int(maxPoint))")
                                    .font(.appBody())
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
                            .frame(width: 350, height: 160) // minimum size
                        VStack{
                            // setting max and min values ------------------
                            Text("Current Compression Value:")
                                .font(.appBody())
                            Text("\(Int(currentStatus))")
                                .font(.appBodyBold())
                                .mediumPaddingBottom()
                            HStack{
                                Text("Set as:")
                                    .font(.appBody())
                                Button("Minimum"){
                                    bsm.minChange(for: currentStatus)
                                }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue.opacity(0.9))
                                    .foregroundStyle(.white)
                                    .font(.appBody())
                                    .padding(.horizontal, 5)
                                    
                                
                                Button("Maximum"){
                                    bsm.maxChange(for: currentStatus)
                                }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue.opacity(0.9))
                                    .foregroundStyle(.white)
                                    .font(.appBody())
                                    .padding(.horizontal, 5)
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
