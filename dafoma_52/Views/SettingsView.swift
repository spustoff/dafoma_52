//
//  SettingsView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var analyticsService = AnalyticsService.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("defaultTaskCategory") private var defaultTaskCategory = "General"
    @AppStorage("defaultNoteCategory") private var defaultNoteCategory = "General"
    @AppStorage("showCompletedTasks") private var showCompletedTasks = true
    
    @State private var showingDataManagement = false
    @State private var showingAbout = false
    @State private var showingOnboarding = false
    @State private var showingDeleteConfirmation = false
    
    private let persistenceService = DataPersistenceService.shared
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                userProfileSection
                
                // App Preferences
                appPreferencesSection
                
                // Default Categories
                defaultCategoriesSection
                
                // Productivity Insights
                productivityInsightsSection
                
                // Data Management
                dataManagementSection
                
                // Support & Info
                supportSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .sheet(isPresented: $showingDataManagement) {
            DataManagementView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your tasks, notes, and settings. This action cannot be undone.")
        }
    }
    
    // MARK: - User Profile Section
    
    private var userProfileSection: some View {
        Section {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ChronicleSpark User")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Productivity enthusiast")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - App Preferences
    
    private var appPreferencesSection: some View {
        Section(header: Text("App Preferences")) {
            
            Toggle("Show Completed Tasks", isOn: $showCompletedTasks)
            
            Button("Reset Onboarding") {
                showingOnboarding = true
            }
            .foregroundColor(.blue)
        }
    }
    
    // MARK: - Default Categories
    
    private var defaultCategoriesSection: some View {
        Section(header: Text("Default Categories")) {
            HStack {
                Text("Default Task Category")
                Spacer()
                TextField("Category", text: $defaultTaskCategory)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Default Note Category")
                Spacer()
                TextField("Category", text: $defaultNoteCategory)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Productivity Insights
    
    private var productivityInsightsSection: some View {
        Section(header: Text("Productivity Overview")) {
            let stats = analyticsService.getTotalStats()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tasks Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(stats.tasks)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tasks Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(stats.completed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(stats.notes)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .padding(.vertical, 8)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focus Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(stats.focusTime))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focus Sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(stats.sessions)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Data Management
    
    private var dataManagementSection: some View {
        Section(header: Text("Data Management")) {
            HStack {
                Text("Data Size")
                Spacer()
                Text(persistenceService.getDataSize())
                    .foregroundColor(.secondary)
            }
            
            Button("Reset Analytics") {
                analyticsService.resetAnalytics()
            }
            .foregroundColor(.orange)
            
            Button("Delete All Data") {
                showingDeleteConfirmation = true
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Support Section
    
    private var supportSection: some View {
        Section(header: Text("Support & Information")) {
            Button("About ChronicleSpark") {
                showingAbout = true
            }
            .foregroundColor(.blue)
            
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func deleteAllData() {
        persistenceService.clearAllData()
        analyticsService.resetAnalytics()
        
        // Reset app storage values
        hasCompletedOnboarding = false
        defaultTaskCategory = "General"
        defaultNoteCategory = "General"
        showCompletedTasks = true
    }
}

// MARK: - Data Management View

struct DataManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    private let persistenceService = DataPersistenceService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Options")) {
                    Button("Export as Text") {
                        exportAsText()
                    }
                    
                    Button("Share Data") {
                        shareData()
                    }
                }
                
                Section(header: Text("Data Information")) {
                    HStack {
                        Text("Total Data Size")
                        Spacer()
                        Text(persistenceService.getDataSize())
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Your data is stored locally on your device and is not shared with any third parties.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Data Management")
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
    
    private func exportAsText() {
        // Implementation for exporting data as text
    }
    
    private func shareData() {
        let data = persistenceService.exportData()
        // Implementation for sharing data
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon and title
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("ChronicleSpark Up")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                        
                        Text("ChronicleSpark Up is a productivity and reference iOS app designed to enhance time management and note-taking capabilities. The app integrates a vibrant and energetic design, leveraging visual insights to help users optimize their schedules and improve their day-to-day productivity.")
                            .font(.body)
                            .lineLimit(nil)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureItem(icon: "chart.bar.fill", text: "Dynamic Time Allocation with visual insights")
                            FeatureItem(icon: "lightbulb.fill", text: "Intelligent Task Suggestions")
                            FeatureItem(icon: "timer", text: "Focus Mode with Pomodoro Timer")
                            FeatureItem(icon: "link", text: "Cross-Reference Insights")
                        }
                    }
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Credits")
                            .font(.headline)
                        
                        Text("Built with SwiftUI and designed following Apple's Human Interface Guidelines.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("About")
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

// MARK: - Feature Item Component

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
