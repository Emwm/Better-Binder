//
//  CalibrationView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-28.
//

import SwiftUI
struct CalibrationView: View {
    @Environment(BindManager.self) private var bsm
    @Environment(BLEManager.self) private var ble
        
    private var connectionLabel: String {
        if ble.isScanning { return "Scanning…" }
        return ble.isConnected ? "Connected" : "Not connected"
    }
    
    // marker model
    struct GaugeMarker: Identifiable {
        let id = UUID()
        let percentage: Double  // 0.0 ... 1.0
        let label: String
        let color: Color
    }
    
    // overlay markers
    struct LinearGaugeMarkersOverlay: View {
        let markers: [GaugeMarker]
        let maxClamp: Double

        var body: some View {
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    ForEach(markers) { marker in
                        let clamped = min(max(marker.percentage, 0), maxClamp) // clamp 0...maxClamp
                        let x = proxy.size.width * clamped
                        
                        VStack(spacing: 4) {
                            // Marker line
                            Rectangle()
                                .fill(marker.color)
                                .frame(width: 5, height: 25)
                                .offset(x: -1) // center the 2pt line on x
                            
                            // Label
                            Text(marker.label)
                                .font(.appSmallCaption())
                                .foregroundStyle(marker.color)
                                .fixedSize()
                        }
                        .position(x: x, y: 0) // anchor at top, x at computed position
                    }
                }
            }
            .allowsHitTesting(false) // pass touches through to underlying controls
        }
    }
    
    var body: some View {
        
        let currentStatus = Double(bsm.rawInt)
        let compValue = Double(bsm.perCompression)
        let paddingValue = 1.4+bsm.overCompressionGap
        let paddingFrac = (paddingValue-1)/2

        
        let markers: [GaugeMarker] = [
            .init(percentage: Double(bsm.minPercent + paddingFrac/paddingValue-0.01), label: "Loose: \(Int(bsm.minValue))", color: .gray),
            .init(percentage: Double(bsm.maxPercent - (paddingFrac)/paddingValue), label: "Compressed: \(Int(bsm.maxValue))", color: .colorDarkBlue)
        ]

        ScrollView{
            VStack{
                Text("Compression Calibration")
                    .font(.appSubHeader())
                    .largePaddingBottom()
                
                Text("Device Connection:")
                    .font(.appBody())
                Text(connectionLabel)
                    .font(.appBodyBold())
                    .mediumPaddingBottom()
                
                Text("Current Compression State:")
                    .font(.appBody())
                Text("\(String(describing: bsm.currentState))")
                    .font(.appBodyBold())
                    .mediumPaddingBottom()
                
                ZStack{
                    Text("Binding Range")
                        .font(.appSmallCaption())
                        .foregroundStyle(Color.colorGreen)
                        .padding(.top, 8)
                    
                    // gauge visual --------------------------
                    Gauge(value: compValue+paddingFrac, in: 0...paddingValue+0.1){
                        Text("Percentage Compressed:")
                            .font(.appBody())
                        
                        //String(format: "%02d:%02d.%02ds", hh, mm, ss)
                        Text("\(Decimal(compValue*100).formatted(.number.precision(.fractionLength(0))))%")
                            .font(.appBodyBold())
                            .largePaddingBottom()
                    } currentValueLabel: {
                        //                        VStack{
                        //                            HStack{
                        //                                Text("Loose: \(Int(minPoint))")
                        //                                    .font(.appBody())
                        //                                Spacer()
                        //                                Text("Compressed: \(Int(maxPoint))")
                        //                                    .font(.appBody())
                        //                            }
                        //                            .padding(.bottom, 10)
                        //                        }
                    }
                    .tint(fillColor(for: compValue))
                    .gaugeStyle(.linearCapacity) // Or .accessoryCircular
                    .animation(.spring(), value: currentStatus)
                    .padding(.horizontal)
                    .overlay {
                        // Align markers to the gauge’s content width
                        LinearGaugeMarkersOverlay(markers: markers, maxClamp: paddingValue)
                            .padding(.horizontal) // match Gauge’s horizontal padding for alignment
                            .frame(height: 16, alignment: .bottom) // height for markers + labels
                            .offset(y: 62) // adjust vertical position so lines sit on top of the track
                    }
                    .largePaddingBottom()
                }
                
                // setting values visual -----------------------
                ZStack{
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                        .frame(width: 350, height: 300) // minimum size
                    VStack{
                        // setting max and min values ------------------
                        Text("Current Compression Value:")
                            .font(.appBody())
                        Text("\(Int(currentStatus))")
                            .font(.appBodyBold())
                            .mediumPaddingBottom()
                        
                        Text("Set Binding Range:")
                            .font(.appBody())
                        
                        HStack{
                            Button("Minimum"){
                                bsm.minChange(for: currentStatus)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.colorMediumBlue.opacity(0.9))
                            .foregroundStyle(.white)
                            .font(.appBody())
                            .padding(.horizontal, 5)
                            
                            
                            Button("Maximum"){
                                bsm.maxChange(for: currentStatus)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.colorDarkBlue.opacity(0.9))
                            .foregroundStyle(.white)
                            .font(.appBody())
                            .padding(.horizontal, 5)
                        }
                        .mediumPaddingBottom()
                        
                        Text("Use the above buttons to set your binding range. The minimum value is the point where the binding timer will start and the maxiumim value is where the overcompression will begin")
                            .font(.appSmallCaption())
                            .padding(.horizontal, 50)
                            .opacity(0.7)
                    }
                }
            }
            Spacer()
        }
    }
    
    
    private func fillColor(for value: Double) -> Color {
        if value <= bsm.minPercent {
            return .gray
        } else if value >= bsm.maxPercent+bsm.overCompressionGap {
            return .colorDarkBlue
        } else {
            // This triggers when the value is between 0.1 and 0.9
            return .colorGreen
        }
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
        .environment(BLEManager.mock)
}

