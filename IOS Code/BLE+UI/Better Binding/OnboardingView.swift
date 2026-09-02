//
//  SwiftUIView.swift
//  Better Binding
//
//  Created by Kent and Lia Morley on 2026-09-02.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    
    var body: some View {
        VStack{
            Text("Welcome!")
                .font(.appHeader())
                .foregroundColor(.colorDarkBlue)
                .largePaddingTop()
            
            Button(action: {
                isFirstLaunch = false
            }) {
                Text("Get Started")
                    .font(.appBodyBold())
                    .foregroundColor(.colorWhite)
                    

            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isFirstLaunch: .constant(true))
}
