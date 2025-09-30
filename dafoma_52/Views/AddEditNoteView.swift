//
//  AddEditNoteView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct AddEditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let noteToEdit: Note?
    
    @State private var title = ""
    @State private var content = ""
    @State private var category = "General"
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var isFavorite = false
    
    init(viewModel: NoteViewModel, noteToEdit: Note? = nil) {
        self.viewModel = viewModel
        self.noteToEdit = noteToEdit
        
        if let note = noteToEdit {
            _title = State(initialValue: note.title)
            _content = State(initialValue: note.content)
            _category = State(initialValue: note.category)
            _tags = State(initialValue: note.tags)
            _isFavorite = State(initialValue: note.isFavorite)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title input
                TextField("Note title", text: $title)
                    .font(.title2)
                    .padding()
                    .background(Color(.systemGray6))
                
                // Content editor
                TextEditor(text: $content)
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                
                // Metadata section
                VStack(spacing: 16) {
                    Divider()
                    
                    // Category and favorite
                    HStack {
                        HStack {
                            Text("Category:")
                                .foregroundColor(.secondary)
                            TextField("Category", text: $category)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Spacer()
                        
                        Button(action: { isFavorite.toggle() }) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundColor(isFavorite ? .orange : .secondary)
                                .font(.title2)
                        }
                    }
                    
                    // Tags section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Add tag input
                        HStack {
                            TextField("Add tag", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add") {
                                addTag()
                            }
                            .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(6)
                        }
                        
                        // Display tags
                        if !tags.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        
                                        Button(action: {
                                            removeTag(tag)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Suggested tags
                        if tags.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Suggestions:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 6) {
                                    ForEach(["work", "personal", "idea", "meeting", "project", "learning"], id: \.self) { suggestion in
                                        Button("#\(suggestion)") {
                                            newTag = suggestion
                                            addTag()
                                        }
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle(noteToEdit == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        if let existingNote = noteToEdit {
            var updatedNote = existingNote
            updatedNote.title = trimmedTitle
            updatedNote.content = content
            updatedNote.category = category
            updatedNote.tags = tags
            updatedNote.isFavorite = isFavorite
            
            viewModel.updateNote(updatedNote)
        } else {
            let newNote = Note(
                title: trimmedTitle,
                content: content,
                tags: tags,
                category: category,
                isFavorite: isFavorite
            )
            
            viewModel.addNote(newNote)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddEditNoteView(viewModel: NoteViewModel())
}
