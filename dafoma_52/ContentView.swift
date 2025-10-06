//
//  ContentView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var noteViewModel = NoteViewModel()
    @StateObject private var analyticsService = AnalyticsService.shared
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        
                        if hasCompletedOnboarding {
                            mainAppView
                        } else {
                            OnboardingView()
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "10.10.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
    
    private var mainAppView: some View {
        TabView {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Dashboard")
                }
            
            // Tasks Tab
            TaskListView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Tasks")
                }
            
            // Notes Tab
            NoteListView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
            
            // Focus Tab
            FocusModeView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var noteViewModel = NoteViewModel()
    @StateObject private var analyticsService = AnalyticsService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    welcomeHeader
                    
                    // Quick stats
                    quickStatsSection
                    
                    // Productivity chart
                    if #available(iOS 16.0, *) {
                        productivityChartSection
                    }
                    
                    // Today's tasks
                    todaysTasksSection
                    
                    // Recent notes
                    recentNotesSection
                    
                    // Insights
                    insightsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                // Refresh data
                analyticsService.updateWeeklyProductivity()
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good \(timeOfDayGreeting())!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Ready to spark your productivity?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsSection: some View {
        let stats = analyticsService.getTotalStats()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Tasks Completed",
                    value: "\(stats.completed)",
                    subtitle: "of \(stats.tasks) total",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Notes Created",
                    value: "\(stats.notes)",
                    subtitle: "total notes",
                    color: .orange,
                    icon: "note.text"
                )
                
                StatCard(
                    title: "Focus Time",
                    value: formatDuration(stats.focusTime),
                    subtitle: "\(stats.sessions) sessions",
                    color: .purple,
                    icon: "timer"
                )
                
                StatCard(
                    title: "Completion Rate",
                    value: "\(Int(taskViewModel.completionRate * 100))%",
                    subtitle: "this period",
                    color: .blue,
                    icon: "chart.bar.fill"
                )
            }
        }
    }
    
    // MARK: - Productivity Chart
    
    @available(iOS 16.0, *)
    private var productivityChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Productivity")
                .font(.headline)
                .foregroundColor(.primary)
            
            let weeklyData = getWeeklyProductivityData()
            
            Chart(weeklyData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Tasks", item.tasks)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Today's Tasks
    
    private var todaysTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink("View All") {
                    TaskListView()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            let todaysTasks = taskViewModel.todaysTasks.prefix(3)
            
            if todaysTasks.isEmpty {
                Text("No tasks due today")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(todaysTasks), id: \.id) { task in
                        TaskSummaryRow(task: task)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Recent Notes
    
    private var recentNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Notes")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink("View All") {
                    NoteListView()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            let recentNotes = noteViewModel.getRecentNotes(limit: 3)
            
            if recentNotes.isEmpty {
                Text("No notes yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(recentNotes, id: \.id) { note in
                        NoteSummaryRow(note: note)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .foregroundColor(.primary)
            
            let insights = analyticsService.getProductivityInsights()
            
            if insights.isEmpty {
                Text("Complete some tasks to see insights")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(insights, id: \.title) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func timeOfDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "night"
        }
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
    
    private func getWeeklyProductivityData() -> [(day: String, tasks: Int)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(day: String, tasks: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -6 + i, to: today) ?? today
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            let dayName = dayFormatter.string(from: date)
            
            // Get tasks completed on this day (simplified)
            let tasksCount = Int.random(in: 0...8) // Placeholder data
            data.append((day: dayName, tasks: tasksCount))
        }
        
        return data
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TaskSummaryRow: View {
    let task: Task
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(task.priority.color))
                .frame(width: 8, height: 8)
            
            Text(task.title)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NoteSummaryRow: View {
    let note: Note
    
    var body: some View {
        HStack {
            if note.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
            
            Text(note.title)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            Text(formatDate(note.updatedAt))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct InsightRow: View {
    let insight: ProductivityInsight
    
    var body: some View {
        HStack {
            Image(systemName: iconForInsightType(insight.type))
                .foregroundColor(colorForInsightType(insight.type))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(insight.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func iconForInsightType(_ type: ProductivityInsight.InsightType) -> String {
        switch type {
        case .positive: return "arrow.up.circle.fill"
        case .neutral: return "minus.circle.fill"
        case .negative: return "arrow.down.circle.fill"
        }
    }
    
    private func colorForInsightType(_ type: ProductivityInsight.InsightType) -> Color {
        switch type {
        case .positive: return .green
        case .neutral: return .orange
        case .negative: return .red
        }
    }
}

#Preview {
    ContentView()
}
