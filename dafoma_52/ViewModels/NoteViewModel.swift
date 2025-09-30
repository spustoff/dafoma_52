//
//  NoteViewModel.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation
import SwiftUI

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var filteredNotes: [Note] = []
    @Published var searchText: String = "" {
        didSet {
            filterNotes()
        }
    }
    @Published var selectedCategory: String = "All" {
        didSet {
            filterNotes()
        }
    }
    @Published var selectedTag: String = "All" {
        didSet {
            filterNotes()
        }
    }
    @Published var showFavoritesOnly: Bool = false {
        didSet {
            filterNotes()
        }
    }
    
    private let persistenceService = DataPersistenceService.shared
    private let analyticsService = AnalyticsService.shared
    
    init() {
        loadNotes()
        filterNotes()
    }
    
    // MARK: - Note Management
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
        filterNotes()
        analyticsService.trackNoteCreated(note)
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
            filterNotes()
            analyticsService.trackNoteUpdated(note)
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
        filterNotes()
        analyticsService.trackNoteDeleted(note)
    }
    
    func toggleNoteFavorite(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].toggleFavorite()
            saveNotes()
            filterNotes()
        }
    }
    
    // MARK: - Note Linking
    
    func linkNoteToTask(_ noteId: UUID, taskId: UUID) {
        if let noteIndex = notes.firstIndex(where: { $0.id == noteId }) {
            notes[noteIndex].linkToTask(taskId)
            saveNotes()
            filterNotes()
        }
    }
    
    func unlinkNoteFromTask(_ noteId: UUID, taskId: UUID) {
        if let noteIndex = notes.firstIndex(where: { $0.id == noteId }) {
            notes[noteIndex].unlinkFromTask(taskId)
            saveNotes()
            filterNotes()
        }
    }
    
    func getNotesLinkedToTask(_ taskId: UUID) -> [Note] {
        return notes.filter { $0.linkedTaskIds.contains(taskId) }
    }
    
    // MARK: - Filtering and Sorting
    
    private func filterNotes() {
        var filtered = notes
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                note.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by tag
        if selectedTag != "All" {
            filtered = filtered.filter { $0.tags.contains(selectedTag) }
        }
        
        // Filter by favorites
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // Sort by favorites first, then by updated date
        filtered.sort { note1, note2 in
            if note1.isFavorite != note2.isFavorite {
                return note1.isFavorite // Favorites first
            }
            return note1.updatedAt > note2.updatedAt // Most recently updated first
        }
        
        filteredNotes = filtered
    }
    
    // MARK: - Analytics and Insights
    
    var categories: [String] {
        let allCategories = Set(notes.map { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }
    
    var allTags: [String] {
        let allTags = Set(notes.flatMap { $0.tags })
        return ["All"] + Array(allTags).sorted()
    }
    
    var favoriteNotes: [Note] {
        return notes.filter { $0.isFavorite }
    }
    
    func getNotesForCategory(_ category: String) -> [Note] {
        return notes.filter { $0.category == category }
    }
    
    func getNotesWithTag(_ tag: String) -> [Note] {
        return notes.filter { $0.tags.contains(tag) }
    }
    
    func getRecentNotes(limit: Int = 5) -> [Note] {
        return notes
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit)
            .map { $0 }
    }
    
    func getNoteInsights() -> [String] {
        var insights: [String] = []
        
        let totalNotes = notes.count
        if totalNotes > 0 {
            insights.append("You have \(totalNotes) note\(totalNotes == 1 ? "" : "s")")
        }
        
        let favoriteCount = favoriteNotes.count
        if favoriteCount > 0 {
            insights.append("\(favoriteCount) favorite note\(favoriteCount == 1 ? "" : "s")")
        }
        
        let recentlyUpdated = notes.filter { note in
            Calendar.current.isDateInToday(note.updatedAt)
        }.count
        
        if recentlyUpdated > 0 {
            insights.append("\(recentlyUpdated) note\(recentlyUpdated == 1 ? "" : "s") updated today")
        }
        
        let linkedNotes = notes.filter { !$0.linkedTaskIds.isEmpty }.count
        if linkedNotes > 0 {
            insights.append("\(linkedNotes) note\(linkedNotes == 1 ? "" : "s") linked to tasks")
        }
        
        return insights
    }
    
    // MARK: - Search and Discovery
    
    func searchNotes(query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query) ||
            note.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func getRelatedNotes(to note: Note) -> [Note] {
        let commonTags = Set(note.tags)
        return notes.filter { otherNote in
            otherNote.id != note.id &&
            !Set(otherNote.tags).isDisjoint(with: commonTags)
        }
    }
    
    // MARK: - Data Persistence
    
    private func loadNotes() {
        notes = persistenceService.loadNotes()
        if notes.isEmpty {
            // Load sample data for first time users
            notes = Note.sampleNotes
            saveNotes()
        }
    }
    
    private func saveNotes() {
        persistenceService.saveNotes(notes)
    }
}
