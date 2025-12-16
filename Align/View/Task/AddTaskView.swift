import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var taskToEdit: AlignTask?
    var prefilledDate: Date
    
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Task Title", text: $title)
                
                DatePicker("Start Time", selection: $startTime)
                DatePicker("End Time", selection: $endTime)
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                }
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    func setupInitialValues() {
        if let task = taskToEdit {
            title = task.title
            startTime = task.startTime
            endTime = task.endTime
        } else {
            startTime = prefilledDate
            endTime = prefilledDate.addingTimeInterval(3600)
        }
    }
    
    func saveTask() {
        if let task = taskToEdit {
            task.title = title
            task.startTime = startTime
            task.endTime = endTime
        } else {
            let newTask = AlignTask(
                title: title,
                startTime: startTime,
                endTime: endTime,
                icon: "circle.fill",
                colorName: "Blue"
            )
            context.insert(newTask)
        }
    }
}
