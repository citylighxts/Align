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
                        animationNamespace: animationNamespace
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
                        TaskFormView(taskToEdit: nil, defaultDate: viewModel.selectedDate)
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
                        .presentationBackground(.clear)
                    }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    let task = AlignTask(title: "Meeting", startTime: Date(), endTime: Date(), icon: "star.fill", colorName: "Purple")
    container.mainContext.insert(task)
    return ContentView().modelContainer(container)
}
