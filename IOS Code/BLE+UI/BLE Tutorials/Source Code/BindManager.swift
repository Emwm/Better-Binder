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
    case binding = "Safe level of Compression"
    case overCompressed = "Over compressed"
}

@Observable
class BindManager {
    
    //read only variables, inital values, userdefaults keeps the state through app closure
    private(set) var currentState: CompressionState = {
        if let savedStateString = UserDefaults.standard.string(forKey: "savedCompressionState"),
           let savedState = CompressionState(rawValue: savedStateString) {
            return savedState
        }
        return .loose
    }() {
        didSet {
            if oldValue != currentState {
                // if we see a state change, update the new stored value to the new state
                UserDefaults.standard.set(currentState.rawValue, forKey: "savedCompressionState")
            }
        }
    }
    
    
    //binding fractions for determining ranges
    private(set) var maxPercent: Double = 1
    private(set) var minPercent: Double = 0
    //this is a invisible value that adjusts the range of overcompression, we do not really want people tightinging a binder until it hurts
    private(set) var overCompressionGap: Double = 0.1
    
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
        perCompression = percentage
        // Temporarily store the old state to check for transitions
        let oldState = self.currentState
        
        //setting state based on what we got, numbers should change
        if self.perCompression < minPercent {
                    self.currentState = .loose
        } else if self._perCompression > maxPercent+overCompressionGap {
                    self.currentState = .overCompressed
                } else {
                    self.currentState = .binding
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
                
            case .binding:
                //binding logic, start timer?
                if(timer.state == .idle){
                    timer.start()
                }
                
            case .overCompressed:
                //over compressed logic, send notificaiton?
                print("too tight")
                
            }
        }
    

}
