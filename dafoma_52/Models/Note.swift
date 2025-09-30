//
//  Note.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

struct Note: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var content: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var tags: [String] = []
    var linkedTaskIds: [UUID] = []
    var category: String = "General"
    var isFavorite: Bool = false
    
    mutating func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }
    
    mutating func updateTitle(_ newTitle: String) {
        title = newTitle
        updatedAt = Date()
    }
    
    mutating func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
            updatedAt = Date()
        }
    }
    
    mutating func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        updatedAt = Date()
    }
    
    mutating func linkToTask(_ taskId: UUID) {
        if !linkedTaskIds.contains(taskId) {
            linkedTaskIds.append(taskId)
            updatedAt = Date()
        }
    }
    
    mutating func unlinkFromTask(_ taskId: UUID) {
        linkedTaskIds.removeAll { $0 == taskId }
        updatedAt = Date()
    }
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
        updatedAt = Date()
    }
}

extension Note {
    static let sampleNotes = [
        Note(title: "Meeting Notes - Q3 Review", content: "Key points discussed:\n• Revenue increased by 15%\n• Customer satisfaction at 92%\n• Need to focus on mobile optimization\n• Next quarter goals: expand team, launch new features", tags: ["work", "meeting", "quarterly"], category: "Work"),
        Note(title: "SwiftUI Best Practices", content: "Important concepts to remember:\n• Use @State for simple local state\n• @ObservedObject for external data\n• @EnvironmentObject for shared data\n• Keep views small and focused\n• Extract complex logic to ViewModels", tags: ["development", "swiftui", "ios"], category: "Learning", isFavorite: true),
        Note(title: "Weekend Trip Ideas", content: "Potential destinations:\n• Napa Valley - wine tasting\n• Big Sur - hiking and nature\n• San Diego - beaches and zoo\n• Lake Tahoe - outdoor activities\n\nBudget: $500-800\nDates: Next weekend", tags: ["travel", "personal", "planning"], category: "Personal"),
        Note(title: "Book Recommendations", content: "Must-read books:\n• 'Atomic Habits' by James Clear\n• 'The Design of Everyday Things' by Don Norman\n• 'Thinking, Fast and Slow' by Daniel Kahneman\n• 'Clean Code' by Robert Martin", tags: ["books", "learning", "self-improvement"], category: "Learning")
    ]
}
