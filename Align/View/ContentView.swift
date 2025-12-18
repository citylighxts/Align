import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) var context
    @Query private var allTasks: [AlignTask]
    @Namespace private var animationNamespace
    
    @State private var showCalendarPicker = false
    @State private var showPersistentTaskList = true
    @State private var currentDetent: PresentationDetent = .fraction(0.80)
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HomeHeaderView(
                        viewModel: viewModel,
                        allTasks: allTasks,
                        showCalendarPicker: $showCalendarPicker,
                        animationNamespace: animationNamespace,
                        isTaskListMinimized: currentDetent == .fraction(0.15)
                    )
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            
            .sheet(isPresented: $showPersistentTaskList) {
                TaskSheetContentView(viewModel: viewModel)
                    .presentationCornerRadius(30)
                    .presentationBackground(.white)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.fraction(0.15), .fraction(0.80)], selection: $currentDetent)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
                
                    .sheet(isPresented: $viewModel.showAddSheet) {
                        TaskFormView(
                            taskToEdit: nil,
                            defaultDate: viewModel.initialStartTime ?? viewModel.selectedDate
                        )
                    }
                    .sheet(item: $viewModel.taskToEdit) { task in
                        TaskFormView(taskToEdit: task)
                    }
                
                    .fullScreenCover(isPresented: $showCalendarPicker) {
                        ZStack(alignment: .bottom) {
                            Color.clear
                                .contentShape(Rectangle())
                                .ignoresSafeArea()
                                .onTapGesture {
                                    showCalendarPicker = false
                                }
                            
                            CustomCalendarBottomPanel(selectedDate: $viewModel.selectedDate, allTasks: allTasks) {
                                showCalendarPicker = false
                            }
                            .transition(.move(edge: .bottom))
                        }
                        .ignoresSafeArea()
                        .presentationBackground(.clear)
                    }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)

    let calendar = Calendar.current
    let now = calendar.date(
        bySettingHour: 9,
        minute: 0,
        second: 0,
        of: calendar.date(byAdding: .day, value: 1, to: Date())!
    )!

    // Task 1: Besok jam 09.00
    let task1 = AlignTask(
        title: "Morning Briefing",
        startTime: now,
        endTime: now.addingTimeInterval(3600),
        icon: "sun.max.fill",
        colorName: "Orange"
    )

    // Task 2: Jam 13.00
    let fourHoursLater = now.addingTimeInterval(4 * 3600)
    let task2 = AlignTask(
        title: "Project Sync",
        startTime: fourHoursLater,
        endTime: fourHoursLater.addingTimeInterval(3600),
        icon: "person.2.fill",
        colorName: "Blue"
    )

    // Task 3: Gap > 4 jam
    let fiveHoursAfterTask2 = fourHoursLater.addingTimeInterval(6 * 3600)
    let task3 = AlignTask(
        title: "Late Night Code",
        startTime: fiveHoursAfterTask2,
        endTime: fiveHoursAfterTask2.addingTimeInterval(3600),
        icon: "laptopcomputer",
        colorName: "Purple"
    )

    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)

    return ContentView()
        .modelContainer(container)
}
