//
//  BindLimitView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/7/26.
//

import SwiftUI

struct BindLimitView: View {
    
    @Environment(\.bindTimer) private var timer
    
    // Holds the raw text input from the user
    @State private var inputText: String = ""
    @State private var errorMessage: String?
    
    
    var body: some View {
        VStack {
            Text("Set New Bind Limit")
                .font(.appSubHeader())

            TextField("Enter limit in hours (e.g. 12.5)", text: $inputText)
                .font(.appBody())
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)
                .mediumPaddingBottom()

            Button("Apply") {
                let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                if let hours = Double(trimmed) {
                    errorMessage = nil
                    let seconds = hours * 3600
                    timer.setDailyBindLimit(seconds: seconds)
                } else {
                    errorMessage = "Please enter a valid number of seconds."
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .font(.appBody())
            .mediumPaddingBottom()

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.appSmallCaption())
            }
            
            Text("If you would like to change the daily binding limit fill in the text box above and apply the new time limit.")
                .font(.appSmallCaption())
                .padding(.horizontal)
                .opacity(0.6)
            
            Spacer()
        }
        .padding()
    }
}
#Preview {
    BindLimitView()
}

