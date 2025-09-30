//
//  FocusModeSettingsView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct FocusModeSettingsView: View {
    @Binding var pomodoroLength: Int
    @Binding var shortBreakLength: Int
    @Binding var longBreakLength: Int
    @Binding var soundEnabled: Bool
    @Binding var vibrationEnabled: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Durations")) {
                    HStack {
                        Text("Focus Session")
                        Spacer()
                        Text("\(pomodoroLength) min")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(pomodoroLength) },
                        set: { pomodoroLength = Int($0) }
                    ), in: 15...60, step: 5) {
                        Text("Focus Duration")
                    } minimumValueLabel: {
                        Text("15m")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("60m")
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Short Break")
                        Spacer()
                        Text("\(shortBreakLength) min")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(shortBreakLength) },
                        set: { shortBreakLength = Int($0) }
                    ), in: 3...15, step: 1) {
                        Text("Short Break Duration")
                    } minimumValueLabel: {
                        Text("3m")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("15m")
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Long Break")
                        Spacer()
                        Text("\(longBreakLength) min")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(longBreakLength) },
                        set: { longBreakLength = Int($0) }
                    ), in: 10...30, step: 5) {
                        Text("Long Break Duration")
                    } minimumValueLabel: {
                        Text("10m")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("30m")
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Sound Alerts", isOn: $soundEnabled)
                    Toggle("Vibration", isOn: $vibrationEnabled)
                }
                
                Section(header: Text("Presets")) {
                    Button("Classic Pomodoro (25/5/15)") {
                        pomodoroLength = 25
                        shortBreakLength = 5
                        longBreakLength = 15
                    }
                    
                    Button("Extended Focus (45/10/20)") {
                        pomodoroLength = 45
                        shortBreakLength = 10
                        longBreakLength = 20
                    }
                    
                    Button("Quick Sessions (15/3/10)") {
                        pomodoroLength = 15
                        shortBreakLength = 3
                        longBreakLength = 10
                    }
                }
            }
            .navigationTitle("Focus Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FocusModeSettingsView(
        pomodoroLength: .constant(25),
        shortBreakLength: .constant(5),
        longBreakLength: .constant(15),
        soundEnabled: .constant(true),
        vibrationEnabled: .constant(true)
    )
}
