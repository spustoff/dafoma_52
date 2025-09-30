//
//  NoteDetailView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    noteHeader
                    
                    // Content
                    noteContent
                    
                    // Metadata
                    noteMetadata
                    
                    // Actions
                    noteActions
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditView = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: { viewModel.toggleNoteFavorite(note) }) {
                            Label(note.isFavorite ? "Remove from Favorites" : "Add to Favorites", 
                                  systemImage: note.isFavorite ? "star.slash" : "star")
                        }
                        
                        Button(action: { shareNote() }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { deleteNote() }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            AddEditNoteView(viewModel: viewModel, noteToEdit: note)
        }
    }
    
    // MARK: - Note Header
    
    private var noteHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if note.isFavorite {
                    Button(action: { viewModel.toggleNoteFavorite(note) }) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Category and dates
            HStack {
                Text(note.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Updated \(formatDate(note.updatedAt))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if !Calendar.current.isDate(note.createdAt, inSameDayAs: note.updatedAt) {
                        Text("Created \(formatDate(note.createdAt))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Note Content
    
    private var noteContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .textSelection(.enabled)
            } else {
                Text("No content")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Note Metadata
    
    private var noteMetadata: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tags
            if !note.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(note.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Linked tasks (if any)
            if !note.linkedTaskIds.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Linked Tasks")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(note.linkedTaskIds.count) task\(note.linkedTaskIds.count == 1 ? "" : "s") linked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Statistics
            VStack(alignment: .leading, spacing: 8) {
                Text("Statistics")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    StatItem(title: "Characters", value: "\(note.content.count)")
                    Spacer()
                    StatItem(title: "Words", value: "\(wordCount(note.content))")
                    Spacer()
                    StatItem(title: "Lines", value: "\(lineCount(note.content))")
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Note Actions
    
    private var noteActions: some View {
        VStack(spacing: 12) {
            // Toggle favorite
            Button(action: {
                viewModel.toggleNoteFavorite(note)
            }) {
                HStack {
                    Image(systemName: note.isFavorite ? "star.slash" : "star.fill")
                    Text(note.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Share note
            Button(action: shareNote) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Note")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Delete note
            Button(action: deleteNote) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Note")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func wordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private func lineCount(_ text: String) -> Int {
        return text.components(separatedBy: .newlines).count
    }
    
    private func shareNote() {
        let shareText = """
        \(note.title)
        
        \(note.content)
        
        Created with ChronicleSpark Up
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func deleteNote() {
        viewModel.deleteNote(note)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Stat Item Component

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NoteDetailView(note: Note.sampleNotes[0], viewModel: NoteViewModel())
}
