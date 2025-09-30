//
//  NoteFiltersView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct NoteFiltersView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Filter")) {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Tag Filter")) {
                    Picker("Tag", selection: $viewModel.selectedTag) {
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            if tag == "All" {
                                Text(tag).tag(tag)
                            } else {
                                Text("#\(tag)").tag(tag)
                            }
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Display Options")) {
                    Toggle("Show Favorites Only", isOn: $viewModel.showFavoritesOnly)
                }
                
                Section(header: Text("Quick Actions")) {
                    Button("Clear All Filters") {
                        viewModel.searchText = ""
                        viewModel.selectedCategory = "All"
                        viewModel.selectedTag = "All"
                        viewModel.showFavoritesOnly = false
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Filters")
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

#Preview {
    NoteFiltersView(viewModel: NoteViewModel())
}
