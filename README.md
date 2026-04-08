Better Binder Project
Overview
The Better Binder is a smart, adjustable chest binder system designed to reduce overbinding-related injuries and promote safer binding practices. By integrating hardware sensors with a companion iOS application, the system actively monitors compression levels and automatically tracks bind session durations. 
This is an IGEN 330 project worked on by Tess Buckley, Reese Brogden, Emmett Morley, Sean Song and Stephen Bowman

System Architecture
Hardware Components (our implementation, can be changed)
Microcontroller: Seeed Studio XIAO ESP32-C3

Sensors/Input: Rotary Encoder

Power: DF102443 LiPo Battery

Connectivity: Bluetooth Low Energy (BLE)

iOS Companion App
Framework: SwiftUI

Core Modules:
BLEManager: Handles real-time communication and data streaming from the ESP32-C3.

BindManager: Processes incoming sensor data to determine the current compression state (Loose, Safe, or Too Tight).

BindTimer: Automatically manages session tracking, initiating or pausing the timer based on the active compression state.

Data Persistence: Preivous bind sessions and daily limits are all stored locally, entirely on the phone storage. No critical data is moved off device, or sent over wireless communication.

Key Features
Dynamic Calibration UI: Features a visual gauge allowing users to set custom minimum and maximum points, dynamically displaying real-time compression levels.

Automated Time Tracking: Eliminates manual logging by automatically tracking wear time based on the active physical state of the hardware.

Safety Monitoring: Actively categorizes compression into distinct zones to prevent potentially harmful overbinding.

Getting Started
Hardware Setup
Wire the rotary encoder and DF102443 LiPo battery to the XIAO ESP32-C3.

Flash the microcontroller with the BLE broadcasting firmware. Ensure the service and characteristic UUIDs match the iOS application.

Software Setup
Open the project in Xcode.

Find your developer accuont in VPN settings and ensure it is trusted.

Build and run the app on a physical iOS device (Bluetooth functionality is not ).

Accept the Bluetooth pairing request upon first launch.

Calibration
Navigate to the Calibration View within the app.

Follow the on-screen prompts to set your personalized baseline reference points on the gauge for accurate state tracking.

Binder will now track how long you have been compressed throughout a 24 hour period to help you stay within your set limit.
