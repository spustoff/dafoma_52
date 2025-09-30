//
//  TaskViewModel.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var searchText: String = "" {
        didSet {
            filterTasks()
        }
    }
    @Published var selectedPriority: Task.Priority? {
        didSet {
            filterTasks()
        }
    }
    @Published var selectedCategory: String = "All" {
        didSet {
            filterTasks()
        }
    }
    @Published var showCompletedTasks: Bool = true {
        didSet {
            filterTasks()
        }
    }
    
    private let persistenceService = DataPersistenceService.shared
    private let analyticsService = AnalyticsService.shared
    
    init() {
        loadTasks()
        filterTasks()
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
        filterTasks()
        analyticsService.trackTaskCreated(task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
            filterTasks()
            analyticsService.trackTaskUpdated(task)
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        filterTasks()
        analyticsService.trackTaskDeleted(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = tasks[index]
            if updatedTask.isCompleted {
                updatedTask.markIncomplete()
            } else {
                updatedTask.markCompleted()
            }
            tasks[index] = updatedTask
            saveTasks()
            filterTasks()
            analyticsService.trackTaskToggled(updatedTask)
        }
    }
    
    // MARK: - Filtering and Sorting
    
    private func filterTasks() {
        var filtered = tasks
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by priority
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by completion status
        if !showCompletedTasks {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Sort by priority and due date
        filtered.sort { task1, task2 in
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted // Incomplete tasks first
            }
            
            if task1.priority.sortOrder != task2.priority.sortOrder {
                return task1.priority.sortOrder < task2.priority.sortOrder
            }
            
            if let date1 = task1.dueDate, let date2 = task2.dueDate {
                return date1 < date2
            } else if task1.dueDate != nil {
                return true // Tasks with due dates come first
            } else if task2.dueDate != nil {
                return false
            }
            
            return task1.createdAt > task2.createdAt // Newer tasks first
        }
        
        filteredTasks = filtered
    }
    
    // MARK: - Analytics and Insights
    
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    var overdueTasks: [Task] {
        let now = Date()
        return tasks.filter { task in
            !task.isCompleted && 
            task.dueDate != nil && 
            task.dueDate! < now
        }
    }
    
    var todaysTasks: [Task] {
        let calendar = Calendar.current
        let today = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: today)
        }
    }
    
    var categories: [String] {
        let allCategories = Set(tasks.map { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }
    
    func getTasksForCategory(_ category: String) -> [Task] {
        return tasks.filter { $0.category == category }
    }
    
    func getProductivityInsights() -> [String] {
        var insights: [String] = []
        
        let completedToday = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }.count
        
        if completedToday > 0 {
            insights.append("You completed \(completedToday) task\(completedToday == 1 ? "" : "s") today!")
        }
        
        let overdueCount = overdueTasks.count
        if overdueCount > 0 {
            insights.append("You have \(overdueCount) overdue task\(overdueCount == 1 ? "" : "s")")
        }
        
        let upcomingCount = todaysTasks.filter { !$0.isCompleted }.count
        if upcomingCount > 0 {
            insights.append("\(upcomingCount) task\(upcomingCount == 1 ? "" : "s") due today")
        }
        
        return insights
    }
    
    // MARK: - Data Persistence
    
    private func loadTasks() {
        tasks = persistenceService.loadTasks()
        if tasks.isEmpty {
            // Load sample data for first time users
            tasks = Task.sampleTasks
            saveTasks()
        }
    }
    
    private func saveTasks() {
        persistenceService.saveTasks(tasks)
    }
}
