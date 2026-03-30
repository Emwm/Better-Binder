//
//  BindManager.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/29/26.
//
import Foundation
import Observation
import SwiftUI

enum CompressionState: String {
    case loose = "Loose"
    case safe = "Safe level of Compression"
    case tooTight = "Over compressed"
}

@Observable
class BindManager {
    
    //read only variables, inital values
    private(set) var currentState: CompressionState = .loose {
        didSet {
            if oldValue != currentState{
                //stateChange(
            }
        }
    }
    
    private(set) var perCompression: Double = 0.0
    private(set) var rawInt: Double = 0.0
    
    private(set) var minValue: Double = UserDefaults.standard.double(forKey: "minCompression") == 0 ? 50 : UserDefaults.standard.double(forKey: "minCompression")
    private(set) var maxValue: Double = UserDefaults.standard.double(forKey: "maxCompression") == 0 ? 3500 : UserDefaults.standard.double(forKey: "maxCompression")
    
    //functions that update global variables for reading
    func maxChange(for value: Double) {
        maxValue = value
        UserDefaults.standard.set(value, forKey: "maxCompression")
    }
    
    func minChange(for value: Double) {
        minValue = value
        UserDefaults.standard.set(value, forKey: "minCompression")
    }
    
    func setRawInt(for value: Double, timer: BindTimer){
        rawInt = value
        updateCompression(rawSensorVal: value, timer: timer)
    }
    
    func updateCompression(rawSensorVal: Double, timer: BindTimer){
        let span = maxValue - minValue
        // Prevent division by zero
        guard span != 0 else { return }
        // Calculate percentage: (Current - Min) / Span
        let percentage = (rawSensorVal - minValue) / span
        // Clamp it between 0 and 1
        perCompression = max(0, min(percentage, 1.0))
        
        // Temporarily store the old state to check for transitions
        let oldState = self.currentState
        
        //setting state based on what we got, numbers should change
        if self._perCompression < 0.01 {
                    self.currentState = .loose
        } else if self._perCompression > 0.99 {
                    self.currentState = .tooTight
                } else {
                    self.currentState = .safe
                }
        
        //binding logic
        if oldState != self.currentState {
                    StateChange(newState: self.currentState, timer: timer)
                }

    }
    
    private func StateChange(newState: CompressionState, timer: BindTimer) {
            switch newState {
            case .loose:
                //binder off state, stop timer?
                timer.stop()
                
            case .safe:
                //binding logic, start timer?
                if(timer.state == .idle){
                    timer.start()
                }
                
            case .tooTight:
                //over compressed logic, send notificaiton?
                print("too tight")
                
            }
        }
    

}
