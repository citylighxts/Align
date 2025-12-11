import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var taskToEdit: AlignTask?
    var defaultDate: Date = Date()
    
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var selectedColorName: String = "Purple"
    @State private var selectedIcon: String = "star.fill"
    
    let icons = ["star.fill", "laptopcomputer", "book.fill", "cup.and.saucer.fill", "figure.run", "bed.double.fill", "cart.fill", "gamecontroller.fill"]
    let colorNames = ["Purple", "Pink", "Teal", "Orange", "Blue", "Gray"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("What needs to be done?", text: $title)
                        .font(.headline)
                    
                    DatePicker("Starts", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Ends", selection: $endTime, in: startTime..., displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Theme")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colorNames, id: \.self) { name in
                                Circle()
                                    .fill(name.toColor)
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .opacity(selectedColorName == name ? 1 : 0)
                                    )
                                    .onTapGesture { selectedColorName = name }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title3)
                                    .padding(10)
                                    .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                                    .onTapGesture { selectedIcon = icon }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(taskToEdit == nil ? "Save" : "Update") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    startTime = task.startTime
                    endTime = task.endTime
                    selectedColorName = task.colorName
                    selectedIcon = task.icon
                } else {
                    let calendar = Calendar.current
                    if let newStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: defaultDate) {
                        startTime = newStart
                        endTime = newStart.addingTimeInterval(3600)
                    }
                }
            }
        }
    }
    
    func saveTask() {
        if let task = taskToEdit {
            task.title = title
            task.startTime = startTime
            task.endTime = endTime
            task.icon = selectedIcon
            task.colorName = selectedColorName
            
            NotificationManager.shared.scheduleNotification(for: task)
            
        } else {
            let newTask = AlignTask(title: title, startTime: startTime, endTime: endTime, icon: selectedIcon, colorName: selectedColorName)
            context.insert(newTask)
            NotificationManager.shared.scheduleNotification(for: newTask)
        }
        
        dismiss()
    }
}
