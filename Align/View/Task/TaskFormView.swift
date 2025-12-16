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
    
    let colorNames = ["Purple", "Pink", "Teal", "Orange", "Blue", "Gray"]
    
    let icons = [
        // General
        "star.fill", "sparkles", "bookmark.fill", "flag.fill", "checkmark.circle.fill",
        // Work & Study
        "briefcase.fill", "laptopcomputer", "doc.text.fill", "book.fill", "graduationcap.fill", "pencil.and.ruler.fill",
        // Home & Lifestyle
        "house.fill", "building.2.fill", "cart.fill", "basket.fill", "gift.fill", "creditcard.fill",
        // Food & Drink
        "cup.and.saucer.fill", "fork.knife", "wineglass.fill", "birthday.cake.fill",
        // Health & Wellness
        "figure.run", "dumbbell.fill", "heart.fill", "brain.head.profile", "bed.double.fill", "pills.fill",
        // Leisure & Tech
        "gamecontroller.fill", "tv.fill", "headphones", "music.note", "camera.fill", "paintbrush.fill",
        // Travel & Nature
        "car.fill", "airplane", "bus.fill", "tram.fill", "leaf.fill", "pawprint.fill", "sun.max.fill", "moon.fill"
    ]
    let iconLayout = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("What needs to be done?", text: $title)
                        .font(.headline)
                    
                    DatePicker("Starts", selection: $startTime, displayedComponents: .hourAndMinute)
                    // Validasi: End time tidak boleh sebelum Start time
                    DatePicker("Ends", selection: $endTime, in: startTime..., displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Theme")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(colorNames, id: \.self) { name in
                                Circle()
                                    .fill(name.toColor.gradient)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .opacity(selectedColorName == name ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring()) { selectedColorName = name }
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 5)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: iconLayout, spacing: 15) {
                            ForEach(icons, id: \.self) { icon in
                                ZStack {
                                    if selectedIcon == icon {
                                        Circle()
                                            .fill(selectedColorName.toColor.opacity(0.2))
                                            .frame(width: 44, height: 44)
                                    }
                                    Image(systemName: icon)
                                        .font(.title3)
                                        .foregroundColor(selectedIcon == icon ? selectedColorName.toColor : .gray)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring()) { selectedIcon = icon }
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 5)
                    }
                    .frame(height: 110)
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
                    // MODE EDIT
                    title = task.title
                    startTime = task.startTime
                    endTime = task.endTime
                    selectedColorName = task.colorName
                    selectedIcon = task.icon
                } else {
                    startTime = defaultDate
                    endTime = defaultDate.addingTimeInterval(3600) // Default 1 jam
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
