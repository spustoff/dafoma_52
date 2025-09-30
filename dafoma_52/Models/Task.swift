//
//  Task.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

struct Task: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var dueDate: Date?
    var priority: Priority
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var completedAt: Date?
    var estimatedDuration: TimeInterval? // in seconds
    var actualDuration: TimeInterval? // in seconds
    var category: String = "General"
    var linkedNoteIds: [UUID] = []
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        
        var color: String {
            switch self {
            case .low: return "green"
            case .medium: return "yellow"
            case .high: return "orange"
            case .urgent: return "red"
            }
        }
        
        var sortOrder: Int {
            switch self {
            case .urgent: return 0
            case .high: return 1
            case .medium: return 2
            case .low: return 3
            }
        }
    }
    
    init(title: String, description: String, dueDate: Date? = nil, priority: Priority, category: String = "General", estimatedDuration: TimeInterval? = nil) {
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.estimatedDuration = estimatedDuration
    }
    
    mutating func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }
    
    mutating func markIncomplete() {
        isCompleted = false
        completedAt = nil
    }
}

extension Task {
    static let sampleTasks = [
        Task(title: "Review quarterly reports", description: "Analyze Q3 performance metrics and prepare summary", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), priority: .high, category: "Work"),
        Task(title: "Plan weekend trip", description: "Research destinations and book accommodations", dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()), priority: .medium, category: "Personal"),
        Task(title: "Complete SwiftUI tutorial", description: "Finish the advanced animations chapter", priority: .low, category: "Learning"),
        Task(title: "Call dentist", description: "Schedule annual checkup appointment", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), priority: .urgent, category: "Health")
    ]
}
