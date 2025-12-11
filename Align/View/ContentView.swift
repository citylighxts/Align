import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) var context
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button("Today") {
                                withAnimation { viewModel.jumpToToday() }
                            }
                            .font(.caption)
                            .padding(6)
                            .background(Capsule().stroke(Color.gray.opacity(0.5)))
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
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    
    let coffeeTask = AlignTask(
        title: "Coffee",
        startTime: Date(),
        endTime: Date().addingTimeInterval(1800),
        icon: "cup.and.saucer.fill",
        colorName: "Purple"
    )
    
    container.mainContext.insert(coffeeTask)
    
    return ContentView()
        .modelContainer(container)
}
