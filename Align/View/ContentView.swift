import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) var context
    
    @Namespace private var animationNamespace
    
    @State private var showCalendarPicker = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 15) {
                        
                        HStack {
                            Button(action: {
                                showCalendarPicker = true
                            }) {
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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                let week = viewModel.selectedDate.fetchWeek()
                                
                                ForEach(week, id: \.self) { day in
                                    let dayStart = day.startOfDay
                                    
                                    VStack(spacing: 6) {
                                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(dayStart == viewModel.selectedDate ? .white : .gray)
                                        
                                        Text(day.formatted(.dateTime.day()))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(dayStart == viewModel.selectedDate ? .white : .primary)
                                    }
                                    .frame(width: 45, height: 70)
                                    .background(
                                        ZStack {
                                            if dayStart == viewModel.selectedDate {
                                                Capsule()
                                                    .fill(Color.blue.gradient)
                                                    .matchedGeometryEffect(id: "CURRENTDAY", in: animationNamespace)
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        withAnimation { viewModel.selectedDate = dayStart }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    TabView(selection: $viewModel.selectedDate) {
                        ForEach(viewModel.calendarPages, id: \.self) { date in
                            DailyTaskList(date: date) { task in
                                viewModel.taskToEdit = task
                            }
                            .padding(.top, 20)
                            .tag(date)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: viewModel.selectedDate)
                    
                }
                
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
                .padding()
            }
            .navigationBarHidden(true)
            
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    
    let coffeeTask = AlignTask(
        title: "Coffee Break",
        startTime: Date().addingTimeInterval(1800),
        endTime: Date().addingTimeInterval(3600),
        icon: "cup.and.saucer.fill",
        colorName: "Purple"
    )
    
    let meetingTask = AlignTask(
        title: "Team Meeting",
        startTime: Date().addingTimeInterval(4800),
        endTime: Date().addingTimeInterval(7200),
        icon: "person.3.fill",
        colorName: "Blue"
    )
    
    container.mainContext.insert(coffeeTask)
    container.mainContext.insert(meetingTask)
    
    return ContentView()
        .modelContainer(container)
}
