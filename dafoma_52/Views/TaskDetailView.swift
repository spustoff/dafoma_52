//
//  TaskDetailView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    taskHeader
                    
                    // Description
                    if !task.description.isEmpty {
                        taskDescription
                    }
                    
                    // Details
                    taskDetails
                    
                    // Actions
                    taskActions
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditView = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            AddEditTaskView(viewModel: viewModel, taskToEdit: task)
        }
    }
    
    // MARK: - Task Header
    
    private var taskHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    viewModel.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(task.isCompleted ? .green : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)
                    
                    HStack {
                        // Priority badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(task.priority.color))
                                .frame(width: 8, height: 8)
                            Text(task.priority.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(task.priority.color).opacity(0.1))
                        .cornerRadius(8)
                        
                        // Category badge
                        Text(task.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Task Description
    
    private var taskDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(task.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Task Details
    
    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Due date
                if let dueDate = task.dueDate {
                    DetailRow(
                        icon: "calendar",
                        title: "Due Date",
                        value: formatDate(dueDate),
                        valueColor: isOverdue(dueDate) ? .red : .primary
                    )
                }
                
                // Estimated duration
                if let duration = task.estimatedDuration {
                    DetailRow(
                        icon: "clock",
                        title: "Estimated Duration",
                        value: formatDuration(duration)
                    )
                }
                
                // Actual duration (if completed)
                if let duration = task.actualDuration {
                    DetailRow(
                        icon: "stopwatch",
                        title: "Actual Duration",
                        value: formatDuration(duration)
                    )
                }
                
                // Created date
                DetailRow(
                    icon: "plus.circle",
                    title: "Created",
                    value: formatDate(task.createdAt)
                )
                
                // Completed date
                if let completedAt = task.completedAt {
                    DetailRow(
                        icon: "checkmark.circle",
                        title: "Completed",
                        value: formatDate(completedAt),
                        valueColor: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Task Actions
    
    private var taskActions: some View {
        VStack(spacing: 12) {
            // Toggle completion
            Button(action: {
                viewModel.toggleTaskCompletion(task)
            }) {
                HStack {
                    Image(systemName: task.isCompleted ? "arrow.counterclockwise" : "checkmark")
                    Text(task.isCompleted ? "Mark Incomplete" : "Mark Complete")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(task.isCompleted ? Color.orange : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Delete task
            Button(action: {
                viewModel.deleteTask(task)
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Task")
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date() && !task.isCompleted
    }
}

// MARK: - Detail Row Component

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color
    
    init(icon: String, title: String, value: String, valueColor: Color = .primary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    TaskDetailView(task: Task.sampleTasks[0], viewModel: TaskViewModel())
}
