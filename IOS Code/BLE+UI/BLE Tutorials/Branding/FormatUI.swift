//
//  FormatUI.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/3/26.
//

import SwiftUI

// this is to format the string for time values
extension Int {
    func asTimestamp() -> String { // call like .asTimestamp() at end of value
        if self <= 0 {
            return "00:00:00"
        }
        let hh = self / 3600
        let mm = (self % 3600) / 60
        let ss = self % 60
        return String(format: "%02d:%02d:%02d", hh, mm, ss)
    }
}

extension View {
    func smallPaddingBottom() -> some View {
        self.padding(.bottom, 2)
    }
    
    func mediumPaddingBottom() -> some View {
        self.padding(.bottom, 10)
    }
    
    func largePaddingBottom() -> some View {
        self.padding(.bottom, 30)
    }
    
    func smallPaddingTop() -> some View {
        self.padding(.top, 2)
    }
    
    func mediumPaddingTop() -> some View {
        self.padding(.top, 10)
    }
    
    func largePaddingTop() -> some View {
        self.padding(.top, 30)
    }
    
}


