//
//  DataPersistenceService.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "ChronicleSpark_Tasks"
    private let notesKey = "ChronicleSpark_Notes"
    private let userPreferencesKey = "ChronicleSpark_UserPreferences"
    private let analyticsDataKey = "ChronicleSpark_Analytics"
    
    private init() {}
    
    // MARK: - Tasks Persistence
    
    func saveTasks(_ tasks: [Task]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: tasksKey)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = userDefaults.data(forKey: tasksKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("Failed to load tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Notes Persistence
    
    func saveNotes(_ notes: [Note]) {
        do {
            let data = try JSONEncoder().encode(notes)
            userDefaults.set(data, forKey: notesKey)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    func loadNotes() -> [Note] {
        guard let data = userDefaults.data(forKey: notesKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("Failed to load notes: \(error)")
            return []
        }
    }
    
    // MARK: - User Preferences
    
    struct UserPreferences: Codable {
        var hasCompletedOnboarding: Bool = false
        var primaryFocusAreas: [String] = []
        var preferredPomodoroLength: Int = 25 // minutes
        var preferredShortBreak: Int = 5 // minutes
        var preferredLongBreak: Int = 15 // minutes
        var notificationsEnabled: Bool = true
        var darkModeEnabled: Bool = false
        var defaultTaskCategory: String = "General"
        var defaultNoteCategory: String = "General"
        var showCompletedTasks: Bool = true
        var autoStartBreaks: Bool = false
        var soundEnabled: Bool = true
        var vibrationEnabled: Bool = true
    }
    
    func saveUserPreferences(_ preferences: UserPreferences) {
        do {
            let data = try JSONEncoder().encode(preferences)
            userDefaults.set(data, forKey: userPreferencesKey)
        } catch {
            print("Failed to save user preferences: \(error)")
        }
    }
    
    func loadUserPreferences() -> UserPreferences {
        guard let data = userDefaults.data(forKey: userPreferencesKey) else {
            return UserPreferences()
        }
        
        do {
            return try JSONDecoder().decode(UserPreferences.self, from: data)
        } catch {
            print("Failed to load user preferences: \(error)")
            return UserPreferences()
        }
    }
    
    // MARK: - Analytics Data
    
    struct AnalyticsData: Codable {
        var tasksCreated: Int = 0
        var tasksCompleted: Int = 0
        var notesCreated: Int = 0
        var pomodoroSessionsCompleted: Int = 0
        var totalFocusTime: TimeInterval = 0 // in seconds
        var dailyStats: [String: DailyStats] = [:] // date string as key
        var weeklyProductivity: [WeeklyProductivity] = []
        
        struct DailyStats: Codable {
            var date: Date
            var tasksCompleted: Int = 0
            var focusTime: TimeInterval = 0
            var pomodoroSessions: Int = 0
            var notesCreated: Int = 0
        }
        
        struct WeeklyProductivity: Codable {
            var weekStartDate: Date
            var totalTasks: Int = 0
            var completedTasks: Int = 0
            var totalFocusTime: TimeInterval = 0
            var averageDailyProductivity: Double = 0
        }
    }
    
    func saveAnalyticsData(_ data: AnalyticsData) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: analyticsDataKey)
        } catch {
            print("Failed to save analytics data: \(error)")
        }
    }
    
    func loadAnalyticsData() -> AnalyticsData {
        guard let data = userDefaults.data(forKey: analyticsDataKey) else {
            return AnalyticsData()
        }
        
        do {
            return try JSONDecoder().decode(AnalyticsData.self, from: data)
        } catch {
            print("Failed to load analytics data: \(error)")
            return AnalyticsData()
        }
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        userDefaults.removeObject(forKey: tasksKey)
        userDefaults.removeObject(forKey: notesKey)
        userDefaults.removeObject(forKey: userPreferencesKey)
        userDefaults.removeObject(forKey: analyticsDataKey)
    }
    
    func exportData() -> [String: Any] {
        return [
            "tasks": loadTasks(),
            "notes": loadNotes(),
            "preferences": loadUserPreferences(),
            "analytics": loadAnalyticsData()
        ]
    }
    
    func getDataSize() -> String {
        let tasksData = userDefaults.data(forKey: tasksKey)?.count ?? 0
        let notesData = userDefaults.data(forKey: notesKey)?.count ?? 0
        let preferencesData = userDefaults.data(forKey: userPreferencesKey)?.count ?? 0
        let analyticsData = userDefaults.data(forKey: analyticsDataKey)?.count ?? 0
        
        let totalBytes = tasksData + notesData + preferencesData + analyticsData
        
        if totalBytes < 1024 {
            return "\(totalBytes) bytes"
        } else if totalBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(totalBytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(totalBytes) / (1024.0 * 1024.0))
        }
    }
}
