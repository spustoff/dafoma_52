//
//  AnalyticsService.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var analyticsData: DataPersistenceService.AnalyticsData
    
    private let persistenceService = DataPersistenceService.shared
    private let calendar = Calendar.current
    
    private init() {
        self.analyticsData = persistenceService.loadAnalyticsData()
    }
    
    // MARK: - Task Analytics
    
    func trackTaskCreated(_ task: Task) {
        analyticsData.tasksCreated += 1
        updateDailyStats { stats in
            // Task creation doesn't directly affect daily stats, but we ensure the day exists
        }
        saveAnalytics()
    }
    
    func trackTaskCompleted(_ task: Task) {
        analyticsData.tasksCompleted += 1
        updateDailyStats { stats in
            stats.tasksCompleted += 1
        }
        saveAnalytics()
    }
    
    func trackTaskUpdated(_ task: Task) {
        // Track task updates for insights
        saveAnalytics()
    }
    
    func trackTaskDeleted(_ task: Task) {
        // Track task deletions for insights
        saveAnalytics()
    }
    
    func trackTaskToggled(_ task: Task) {
        if task.isCompleted {
            trackTaskCompleted(task)
        }
    }
    
    // MARK: - Note Analytics
    
    func trackNoteCreated(_ note: Note) {
        analyticsData.notesCreated += 1
        updateDailyStats { stats in
            stats.notesCreated += 1
        }
        saveAnalytics()
    }
    
    func trackNoteUpdated(_ note: Note) {
        // Track note updates for insights
        saveAnalytics()
    }
    
    func trackNoteDeleted(_ note: Note) {
        // Track note deletions for insights
        saveAnalytics()
    }
    
    // MARK: - Focus/Pomodoro Analytics
    
    func trackPomodoroSessionStarted() {
        // Track when a pomodoro session starts
        saveAnalytics()
    }
    
    func trackPomodoroSessionCompleted(duration: TimeInterval) {
        analyticsData.pomodoroSessionsCompleted += 1
        analyticsData.totalFocusTime += duration
        
        updateDailyStats { stats in
            stats.pomodoroSessions += 1
            stats.focusTime += duration
        }
        
        saveAnalytics()
    }
    
    func trackFocusTime(_ duration: TimeInterval) {
        analyticsData.totalFocusTime += duration
        updateDailyStats { stats in
            stats.focusTime += duration
        }
        saveAnalytics()
    }
    
    // MARK: - Daily Stats Management
    
    private func updateDailyStats(update: (inout DataPersistenceService.AnalyticsData.DailyStats) -> Void) {
        let today = Date()
        let dateKey = dateFormatter.string(from: today)
        
        if var stats = analyticsData.dailyStats[dateKey] {
            update(&stats)
            analyticsData.dailyStats[dateKey] = stats
        } else {
            var newStats = DataPersistenceService.AnalyticsData.DailyStats(date: today)
            update(&newStats)
            analyticsData.dailyStats[dateKey] = newStats
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    // MARK: - Weekly Analytics
    
    func updateWeeklyProductivity() {
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        // Check if we already have data for this week
        if let existingWeek = analyticsData.weeklyProductivity.first(where: { 
            calendar.isDate($0.weekStartDate, inSameDayAs: weekStart) 
        }) {
            // Update existing week data
            updateExistingWeekData(existingWeek, weekStart: weekStart)
        } else {
            // Create new week data
            let newWeek = createNewWeekData(weekStart: weekStart)
            analyticsData.weeklyProductivity.append(newWeek)
        }
        
        // Keep only last 12 weeks of data
        analyticsData.weeklyProductivity = analyticsData.weeklyProductivity
            .sorted { $0.weekStartDate > $1.weekStartDate }
            .prefix(12)
            .map { $0 }
        
        saveAnalytics()
    }
    
    private func updateExistingWeekData(_ week: DataPersistenceService.AnalyticsData.WeeklyProductivity, weekStart: Date) {
        // Update logic for existing week
        if let index = analyticsData.weeklyProductivity.firstIndex(where: { 
            calendar.isDate($0.weekStartDate, inSameDayAs: weekStart) 
        }) {
            analyticsData.weeklyProductivity[index] = calculateWeeklyStats(for: weekStart)
        }
    }
    
    private func createNewWeekData(weekStart: Date) -> DataPersistenceService.AnalyticsData.WeeklyProductivity {
        return calculateWeeklyStats(for: weekStart)
    }
    
    private func calculateWeeklyStats(for weekStart: Date) -> DataPersistenceService.AnalyticsData.WeeklyProductivity {
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        
        var totalTasks = 0
        var completedTasks = 0
        var totalFocusTime: TimeInterval = 0
        var daysWithData = 0
        
        // Iterate through each day of the week
        for dayOffset in 0...6 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            let dayKey = dateFormatter.string(from: day)
            
            if let dayStats = analyticsData.dailyStats[dayKey] {
                completedTasks += dayStats.tasksCompleted
                totalFocusTime += dayStats.focusTime
                daysWithData += 1
            }
        }
        
        let averageProductivity = daysWithData > 0 ? Double(completedTasks) / Double(daysWithData) : 0
        
        return DataPersistenceService.AnalyticsData.WeeklyProductivity(
            weekStartDate: weekStart,
            totalTasks: totalTasks,
            completedTasks: completedTasks,
            totalFocusTime: totalFocusTime,
            averageDailyProductivity: averageProductivity
        )
    }
    
    // MARK: - Insights and Reports
    
    func getProductivityInsights() -> [ProductivityInsight] {
        var insights: [ProductivityInsight] = []
        
        // Daily completion rate
        let today = dateFormatter.string(from: Date())
        if let todayStats = analyticsData.dailyStats[today] {
            if todayStats.tasksCompleted > 0 {
                insights.append(.init(
                    title: "Today's Progress",
                    description: "You completed \(todayStats.tasksCompleted) task\(todayStats.tasksCompleted == 1 ? "" : "s") today",
                    type: .positive
                ))
            }
            
            if todayStats.focusTime > 0 {
                let hours = Int(todayStats.focusTime / 3600)
                let minutes = Int((todayStats.focusTime.truncatingRemainder(dividingBy: 3600)) / 60)
                let timeString = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
                
                insights.append(.init(
                    title: "Focus Time",
                    description: "You focused for \(timeString) today",
                    type: .positive
                ))
            }
        }
        
        // Weekly trends
        if analyticsData.weeklyProductivity.count >= 2 {
            let thisWeek = analyticsData.weeklyProductivity[0]
            let lastWeek = analyticsData.weeklyProductivity[1]
            
            let improvement = thisWeek.completedTasks - lastWeek.completedTasks
            if improvement > 0 {
                insights.append(.init(
                    title: "Weekly Improvement",
                    description: "You completed \(improvement) more task\(improvement == 1 ? "" : "s") than last week",
                    type: .positive
                ))
            } else if improvement < 0 {
                insights.append(.init(
                    title: "Weekly Challenge",
                    description: "You completed \(abs(improvement)) fewer task\(abs(improvement) == 1 ? "" : "s") than last week",
                    type: .neutral
                ))
            }
        }
        
        // Pomodoro insights
        if analyticsData.pomodoroSessionsCompleted > 0 {
            insights.append(.init(
                title: "Focus Sessions",
                description: "You've completed \(analyticsData.pomodoroSessionsCompleted) focus session\(analyticsData.pomodoroSessionsCompleted == 1 ? "" : "s") total",
                type: .positive
            ))
        }
        
        return insights
    }
    
    func getDailyStats(for date: Date) -> DataPersistenceService.AnalyticsData.DailyStats? {
        let dateKey = dateFormatter.string(from: date)
        return analyticsData.dailyStats[dateKey]
    }
    
    func getWeeklyStats() -> [DataPersistenceService.AnalyticsData.WeeklyProductivity] {
        return analyticsData.weeklyProductivity.sorted { $0.weekStartDate > $1.weekStartDate }
    }
    
    func getTotalStats() -> (tasks: Int, completed: Int, notes: Int, focusTime: TimeInterval, sessions: Int) {
        return (
            tasks: analyticsData.tasksCreated,
            completed: analyticsData.tasksCompleted,
            notes: analyticsData.notesCreated,
            focusTime: analyticsData.totalFocusTime,
            sessions: analyticsData.pomodoroSessionsCompleted
        )
    }
    
    // MARK: - Data Management
    
    private func saveAnalytics() {
        persistenceService.saveAnalyticsData(analyticsData)
    }
    
    func resetAnalytics() {
        analyticsData = DataPersistenceService.AnalyticsData()
        saveAnalytics()
    }
}

// MARK: - Supporting Types

struct ProductivityInsight {
    let title: String
    let description: String
    let type: InsightType
    
    enum InsightType {
        case positive
        case neutral
        case negative
    }
}
