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
                    VStack(spacing: 15) {
                        
                        HStack {
                            Button(action: { showCalendarPicker = true }) {
                                HStack(spacing: 8) {
                                    Text(viewModel.selectedDate.formatted(.dateTime.day().month(.wide).year()))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue.opacity(0.8))
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                let week = viewModel.selectedDate.fetchWeek()
                                
                                ForEach(week, id: \.self) { day in
                                    let dayStart = day.startOfDay
                                    let isSelected = dayStart == viewModel.selectedDate
                                    
                                    let tasksForDay = allTasks.filter {
                                        Calendar.current.isDate($0.startTime, inSameDayAs: dayStart)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray)
                                        
                                        ZStack {
                                            if isSelected {
                                                Circle()
                                                    .fill(Color.blue.gradient)
                                                    .matchedGeometryEffect(id: "CURRENTDAY", in: animationNamespace)
                                                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 5)
                                            }
                                            
                                            Text(day.formatted(.dateTime.day()))
                                                .font(.system(size: 16))
                                                .fontWeight(.bold)
                                                .foregroundColor(isSelected ? .white : .primary)
                                        }
                                        .frame(width: 36, height: 36)
                                        
                                        HStack(spacing: -4) {
                                            if tasksForDay.isEmpty {
                                                Circle().fill(.clear).frame(width: 14, height: 14)
                                            } else {
                                                ForEach(tasksForDay.prefix(3)) { task in
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(task.colorName.toColor))
                                                            .frame(width: 14, height: 14)
                                                            .overlay(
                                                                Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 1.5)
                                                            )
                                                        Image(systemName: task.icon)
                                                            .font(.system(size: 6, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            }
                                        }
                                        .frame(height: 14)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 5)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            viewModel.selectedDate = dayStart
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            
            // --- 2. SHEET TASK LIST (Persistent) ---
            .sheet(isPresented: $showPersistentTaskList) {
                ZStack(alignment: .bottomTrailing) {
                    
                    // A. KONTEN LIST
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 5)
                            .padding(.vertical, 10)
                        
                        TabView(selection: $viewModel.selectedDate) {
                            ForEach(viewModel.calendarPages, id: \.self) { date in
                                DailyTaskList(date: date) { task in
                                    viewModel.taskToEdit = task
                                }
                                .tag(date)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .animation(.easeInOut, value: viewModel.selectedDate)
                    }
                    
                    // B. TOMBOL ADD
                    Button(action: { viewModel.showAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.gradient)
                            .clipShape(Circle())
                            .shadow(radius: 5, y: 5)
                    }
                    .padding(25)
                }
                .presentationCornerRadius(30)
                .presentationBackground(.white)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.15), .fraction(0.80)], selection: $currentDetent)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
                
                // --- 3. NESTED SHEETS ---
                .sheet(isPresented: $viewModel.showAddSheet) {
                    TaskFormView(taskToEdit: nil, defaultDate: viewModel.selectedDate)
                }
                .sheet(item: $viewModel.taskToEdit) { task in
                    TaskFormView(taskToEdit: task)
                }
                .sheet(isPresented: $showCalendarPicker) {
                    CalendarSheetView(selectedDate: $viewModel.selectedDate)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    
    let task = AlignTask(title: "Meeting", startTime: Date(), endTime: Date(), icon: "star.fill", colorName: "Purple")
    let task2 = AlignTask(title: "Gym", startTime: Date(), endTime: Date(), icon: "dumbbell.fill", colorName: "Orange")
    
    container.mainContext.insert(task)
    container.mainContext.insert(task2)
    
    return ContentView()
        .modelContainer(container)
}
