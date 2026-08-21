//
//  SwiftUIView.swift
//  BLE Tutorials
//
//  Created by Kent and Lia Morley on 2026-08-20.
//

import SwiftUI

struct yearView: View {
    
    @State private var gridData: [[Color]] = Array(
        repeating: Array(repeating: Color.gray.opacity(0.2), count: 31),
        count: 12
    )
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
   
    
    var body: some View {
        VStack {
            
            Text("Yearly Trend")
                            .font(.title)
                            .bold()
                            .padding(.bottom)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 4){
                    ForEach(0..<12, id: \.self) { monthIndex in
                        VStack(spacing: 3) {
                            
                            //Month label
                            Text(months[monthIndex])
                                .font(.caption)
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
        }

    }
    
    private func dataFill() {
        gridData[0][0] = .green
    }
}

#Preview {
    yearView()
}
