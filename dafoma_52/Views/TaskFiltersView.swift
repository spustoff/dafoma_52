//
//  TaskFiltersView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct TaskFiltersView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Priority Filter")) {
                    Picker("Priority", selection: $viewModel.selectedPriority) {
                        Text("All Priorities").tag(nil as Task.Priority?)
                        
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority as Task.Priority?)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Category Filter")) {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Display Options")) {
                    Toggle("Show Completed Tasks", isOn: $viewModel.showCompletedTasks)
                }
                
                Section(header: Text("Quick Actions")) {
                    Button("Clear All Filters") {
                        viewModel.searchText = ""
                        viewModel.selectedPriority = nil
                        viewModel.selectedCategory = "All"
                        viewModel.showCompletedTasks = true
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
    TaskFiltersView(viewModel: TaskViewModel())
}
