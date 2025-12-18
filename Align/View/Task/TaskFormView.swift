import SwiftUI
import SwiftData

struct TaskFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var taskToEdit: AlignTask?
    var defaultDate: Date = Date()
    
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var selectedColorName: String = "Primary"
    @State private var selectedIcon: String = "bookmark.fill"
    
    let colorNames = ["Purple", "Pink", "Teal", "Orange", "Blue", "Gray"]
    let icons = [
        "star.fill", "sparkles", "bookmark.fill", "flag.fill", "checkmark.circle.fill",
        "briefcase.fill", "laptopcomputer", "doc.text.fill", "book.fill", "graduationcap.fill", "pencil.and.ruler.fill",
        "house.fill", "building.2.fill", "cart.fill", "basket.fill", "gift.fill", "creditcard.fill",
        "cup.and.saucer.fill", "fork.knife", "wineglass.fill", "birthday.cake.fill",
        "figure.run", "dumbbell.fill", "heart.fill", "brain.head.profile", "bed.double.fill", "pills.fill",
        "gamecontroller.fill", "tv.fill", "headphones", "music.note", "camera.fill", "paintbrush.fill",
        "car.fill", "airplane", "bus.fill", "tram.fill", "leaf.fill", "pawprint.fill", "sun.max.fill", "moon.fill"
    ]
    let iconLayout = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                VStack(alignment: .leading) {
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                        
                        VStack(spacing: 4) {
                            TextField("", text: $title, prompt: Text("New Task").foregroundColor(.white.opacity(0.7)))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .tint(.white)
                                .submitLabel(.done)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.white.opacity(0.6))
                                .cornerRadius(1)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 220)
                .background(selectedColorName.toColor)
                
                Form {
                    Section(header: Text("Waktu")) {
                        DatePicker("Mulai", selection: $startTime, displayedComponents: .hourAndMinute)
                            .onChange(of: startTime) {
                                if startTime > endTime {
                                    endTime = startTime.addingTimeInterval(3600)
                                }
                            }
                        
                        DatePicker("Selesai", selection: $endTime, in: startTime..., displayedComponents: .hourAndMinute)
                    }
                    
                    Section(header: Text("Tema")) {
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
                            .padding(10)
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
                            .padding(10)
                        }
                        .frame(height: 110)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(UIColor.systemGroupedBackground))
                
                VStack {
                    Button(action: saveTask) {
                        Text(taskToEdit == nil ? "Create Task" : "Update Task")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty ? Color.gray : selectedColorName.toColor)
                            .cornerRadius(15)
                    }
                    .disabled(title.isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -5)
                
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    startTime = task.startTime
                    endTime = task.endTime
                    selectedColorName = task.colorName
                    selectedIcon = task.icon
                } else {
                    startTime = defaultDate
                    endTime = defaultDate.addingTimeInterval(3600)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    
    return TaskFormView(taskToEdit: nil)
        .modelContainer(container)
}
