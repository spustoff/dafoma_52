//
//  AddEditTaskView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct AddEditTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let taskToEdit: Task?
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Task.Priority.medium
    @State private var category = "General"
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var estimatedDuration: Double = 30 // minutes
    @State private var hasEstimatedDuration = false
    
    init(viewModel: TaskViewModel, taskToEdit: Task? = nil) {
        self.viewModel = viewModel
        self.taskToEdit = taskToEdit
        
        if let task = taskToEdit {
            _title = State(initialValue: task.title)
            _description = State(initialValue: task.description)
            _priority = State(initialValue: task.priority)
            _category = State(initialValue: task.category)
            _dueDate = State(initialValue: task.dueDate ?? Date())
            _hasDueDate = State(initialValue: task.dueDate != nil)
            _estimatedDuration = State(initialValue: (task.estimatedDuration ?? 1800) / 60) // convert to minutes
            _hasEstimatedDuration = State(initialValue: task.estimatedDuration != nil)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $title)
                        .font(.headline)
                    
                    TextField("Description (optional)", text: $description)
                        .lineLimit(3)
                }
                
                Section(header: Text("Priority & Category")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    
                    HStack {
                        Text("Category")
                        Spacer()
                        TextField("Category", text: $category)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Scheduling")) {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Toggle("Estimate duration", isOn: $hasEstimatedDuration)
                    
                    if hasEstimatedDuration {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(Int(estimatedDuration)) min")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $estimatedDuration, in: 5...240, step: 5) {
                            Text("Duration")
                        } minimumValueLabel: {
                            Text("5m")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("4h")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveTask()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        if let existingTask = taskToEdit {
            var updatedTask = existingTask
            updatedTask.title = trimmedTitle
            updatedTask.description = description
            updatedTask.priority = priority
            updatedTask.category = category
            updatedTask.dueDate = hasDueDate ? dueDate : nil
            updatedTask.estimatedDuration = hasEstimatedDuration ? estimatedDuration * 60 : nil // convert to seconds
            
            viewModel.updateTask(updatedTask)
        } else {
            let newTask = Task(
                title: trimmedTitle,
                description: description,
                dueDate: hasDueDate ? dueDate : nil,
                priority: priority,
                category: category,
                estimatedDuration: hasEstimatedDuration ? estimatedDuration * 60 : nil
            )
            
            viewModel.addTask(newTask)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddEditTaskView(viewModel: TaskViewModel())
}
