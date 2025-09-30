//
//  NoteListView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct NoteListView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingAddNote = false
    @State private var showingFilters = false
    @State private var selectedNote: Note?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterBar
                
                // Insights banner
                if !viewModel.getNoteInsights().isEmpty {
                    insightsBanner
                }
                
                // Notes list
                notesList
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddEditNoteView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFilters) {
            NoteFiltersView(viewModel: viewModel)
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailView(note: note, viewModel: viewModel)
        }
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Quick filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        isSelected: !viewModel.showFavoritesOnly && viewModel.selectedCategory == "All" && viewModel.selectedTag == "All",
                        action: {
                            viewModel.showFavoritesOnly = false
                            viewModel.selectedCategory = "All"
                            viewModel.selectedTag = "All"
                        }
                    )
                    
                    FilterChip(
                        title: "Favorites",
                        isSelected: viewModel.showFavoritesOnly,
                        color: .orange,
                        action: {
                            viewModel.showFavoritesOnly.toggle()
                        }
                    )
                    
                    ForEach(viewModel.categories.dropFirst(), id: \.self) { category in
                        FilterChip(
                            title: category,
                            isSelected: viewModel.selectedCategory == category,
                            color: .blue,
                            action: {
                                viewModel.selectedCategory = viewModel.selectedCategory == category ? "All" : category
                            }
                        )
                    }
                    
                    ForEach(viewModel.allTags.dropFirst().prefix(5), id: \.self) { tag in
                        FilterChip(
                            title: "#\(tag)",
                            isSelected: viewModel.selectedTag == tag,
                            color: .green,
                            action: {
                                viewModel.selectedTag = viewModel.selectedTag == tag ? "All" : tag
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Insights Banner
    
    private var insightsBanner: some View {
        let insights = viewModel.getNoteInsights()
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(insights, id: \.self) { insight in
                    InsightCard(text: insight)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Notes List
    
    private var notesList: some View {
        Group {
            if viewModel.filteredNotes.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.filteredNotes) { note in
                        NoteRowView(note: note) {
                            selectedNote = note
                        } onToggleFavorite: {
                            viewModel.toggleNoteFavorite(note)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteNote(note)
                            }
                            
                            Button("Edit") {
                                selectedNote = note
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button(note.isFavorite ? "Unfavorite" : "Favorite") {
                                viewModel.toggleNoteFavorite(note)
                            }
                            .tint(.orange)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No notes found")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(viewModel.searchText.isEmpty ? "Tap + to create your first note" : "Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !viewModel.searchText.isEmpty || viewModel.selectedCategory != "All" || viewModel.selectedTag != "All" || viewModel.showFavoritesOnly {
                Button("Clear Filters") {
                    viewModel.searchText = ""
                    viewModel.selectedCategory = "All"
                    viewModel.selectedTag = "All"
                    viewModel.showFavoritesOnly = false
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Note Row View

struct NoteRowView: View {
    let note: Note
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // Title and favorite
                HStack {
                    Text(note.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if note.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Content preview
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Tags and metadata
                HStack {
                    // Tags
                    if !note.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(note.tags.prefix(3), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .cornerRadius(4)
                                }
                                
                                if note.tags.count > 3 {
                                    Text("+\(note.tags.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Category and date
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(note.category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        
                        Text(formatDate(note.updatedAt))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    NoteListView()
}
