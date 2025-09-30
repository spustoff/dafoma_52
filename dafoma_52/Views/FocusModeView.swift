//
//  FocusModeView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct FocusModeView: View {
    @StateObject private var timerManager = PomodoroTimerManager()
    @AppStorage("preferredPomodoroLength") private var pomodoroLength = 25
    @AppStorage("preferredShortBreak") private var shortBreakLength = 5
    @AppStorage("preferredLongBreak") private var longBreakLength = 15
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    
    @State private var showingSettings = false
    @State private var selectedTask: String = "Focus Session"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Timer display
                timerDisplay
                
                // Progress indicator
                progressIndicator
                
                // Current session info
                sessionInfo
                
                // Control buttons
                controlButtons
                
                // Session statistics
                sessionStats
                
                Spacer()
            }
            .padding()
            .navigationTitle("Focus Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            FocusModeSettingsView(
                pomodoroLength: $pomodoroLength,
                shortBreakLength: $shortBreakLength,
                longBreakLength: $longBreakLength,
                soundEnabled: $soundEnabled,
                vibrationEnabled: $vibrationEnabled
            )
        }
        .onAppear {
            timerManager.configure(
                pomodoroLength: pomodoroLength,
                shortBreakLength: shortBreakLength,
                longBreakLength: longBreakLength,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled
            )
        }
    }
    
    // MARK: - Timer Display
    
    private var timerDisplay: some View {
        VStack(spacing: 16) {
            // Time remaining
            Text(formatTime(timerManager.timeRemaining))
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundColor(timerManager.currentPhase == .work ? .blue : .orange)
                .animation(.easeInOut, value: timerManager.timeRemaining)
            
            // Phase indicator
            Text(timerManager.currentPhase.displayName)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(
                    timerManager.currentPhase == .work ? Color.blue : Color.orange,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerManager.progress)
            
            // Center content
            VStack(spacing: 8) {
                Image(systemName: timerManager.currentPhase == .work ? "brain.head.profile" : "cup.and.saucer")
                    .font(.system(size: 40))
                    .foregroundColor(timerManager.currentPhase == .work ? .blue : .orange)
                
                Text("\(timerManager.completedPomodoros)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Session Info
    
    private var sessionInfo: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Current Task:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(selectedTask)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Session:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(timerManager.currentSession)/4")
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Total Focus Time:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDuration(timerManager.totalFocusTime))
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            // Reset button
            Button(action: {
                timerManager.reset()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .disabled(timerManager.isRunning)
            
            // Play/Pause button
            Button(action: {
                if timerManager.isRunning {
                    timerManager.pause()
                } else {
                    timerManager.start()
                }
            }) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(timerManager.currentPhase == .work ? Color.blue : Color.orange)
                    .clipShape(Circle())
            }
            
            // Skip button
            Button(action: {
                timerManager.skip()
            }) {
                Image(systemName: "forward.end")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Session Stats
    
    private var sessionStats: some View {
        HStack(spacing: 30) {
            StatColumn(
                title: "Today",
                value: "\(timerManager.todaysSessions)",
                subtitle: "sessions"
            )
            
            StatColumn(
                title: "This Week",
                value: "\(timerManager.weekSessions)",
                subtitle: "sessions"
            )
            
            StatColumn(
                title: "Streak",
                value: "\(timerManager.currentStreak)",
                subtitle: "days"
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Column Component

struct StatColumn: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Pomodoro Timer Manager

class PomodoroTimerManager: ObservableObject {
    @Published var timeRemaining: Int = 1500 // 25 minutes in seconds
    @Published var isRunning: Bool = false
    @Published var currentPhase: PomodoroPhase = .work
    @Published var currentSession: Int = 1
    @Published var completedPomodoros: Int = 0
    @Published var totalFocusTime: TimeInterval = 0
    @Published var todaysSessions: Int = 0
    @Published var weekSessions: Int = 0
    @Published var currentStreak: Int = 0
    
    private var timer: Timer?
    private var pomodoroLength: Int = 25 * 60
    private var shortBreakLength: Int = 5 * 60
    private var longBreakLength: Int = 15 * 60
    private var soundEnabled: Bool = true
    private var vibrationEnabled: Bool = true
    
    enum PomodoroPhase {
        case work
        case shortBreak
        case longBreak
        
        var displayName: String {
            switch self {
            case .work: return "Focus Time"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
    }
    
    var progress: Double {
        let totalTime = currentPhase == .work ? pomodoroLength : 
                       currentPhase == .shortBreak ? shortBreakLength : longBreakLength
        return 1.0 - (Double(timeRemaining) / Double(totalTime))
    }
    
    func configure(pomodoroLength: Int, shortBreakLength: Int, longBreakLength: Int, soundEnabled: Bool, vibrationEnabled: Bool) {
        self.pomodoroLength = pomodoroLength * 60
        self.shortBreakLength = shortBreakLength * 60
        self.longBreakLength = longBreakLength * 60
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
        
        if !isRunning {
            timeRemaining = self.pomodoroLength
        }
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        currentPhase = .work
        currentSession = 1
        timeRemaining = pomodoroLength
    }
    
    func skip() {
        completeCurrentPhase()
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            if currentPhase == .work {
                totalFocusTime += 1
            }
        } else {
            completeCurrentPhase()
        }
    }
    
    private func completeCurrentPhase() {
        // Play notification sound/vibration
        if soundEnabled {
            // Play sound (would implement actual sound playing)
        }
        
        if vibrationEnabled {
            // Trigger haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        switch currentPhase {
        case .work:
            completedPomodoros += 1
            todaysSessions += 1
            
            if currentSession % 4 == 0 {
                // Long break after 4 pomodoros
                currentPhase = .longBreak
                timeRemaining = longBreakLength
            } else {
                // Short break
                currentPhase = .shortBreak
                timeRemaining = shortBreakLength
            }
            
        case .shortBreak, .longBreak:
            currentPhase = .work
            timeRemaining = pomodoroLength
            currentSession += 1
        }
        
        // Save analytics
        AnalyticsService.shared.trackPomodoroSessionCompleted(duration: TimeInterval(pomodoroLength))
    }
}

#Preview {
    FocusModeView()
}
