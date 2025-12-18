import SwiftUI
import SwiftData

struct HomeHeaderView: View {
    @ObservedObject var viewModel: HomeViewModel
    var allTasks: [AlignTask]
    @Binding var showCalendarPicker: Bool
    var animationNamespace: Namespace.ID
    
    var isTaskListMinimized: Bool
    
    let hourHeight: CGFloat = 18
    let endHour: Int = 24
    
    var dynamicStartHour: Int? {
        let week = viewModel.selectedDate.fetchWeek()
        let tasksInWeek = allTasks.filter { task in
            week.contains { day in Calendar.current.isDate(task.startTime, inSameDayAs: day) }
        }
        
        if let earliestTask = tasksInWeek.min(by: { $0.startTime < $1.startTime }) {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            let hour = calendar.component(.hour, from: earliestTask.startTime)
            return max(0, hour - 1)
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: { withAnimation(.spring()) { showCalendarPicker = true } }) {
                    HStack(spacing: 8) {
                        Text(viewModel.selectedDate.formatted(.dateTime.day().month(.wide).year()))
                            .font(.title2).fontWeight(.bold).foregroundColor(.primary)
                        Image(systemName: "chevron.right")
                            .font(.body).fontWeight(.bold).foregroundColor(.blue.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal).padding(.top, 10)
            
            HStack(spacing: 0) {
                let startHour = dynamicStartHour
                
                if isTaskListMinimized, startHour != nil {
                    Spacer().frame(width: 25)
                }
                
                let week = viewModel.selectedDate.fetchWeek()
                
                ForEach(week, id: \.self) { day in
                    let dayStart = day.startOfDay
                    let isSelected = dayStart == viewModel.selectedDate
                    
                    VStack(spacing: 8) {
                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.caption).fontWeight(.semibold).foregroundColor(.gray)
                        
                        ZStack {
                            if isSelected {
                                Circle().fill(Color.blue.gradient)
                                    .matchedGeometryEffect(id: "CURRENTDAY", in: animationNamespace)
                                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 5)
                            }
                            Text(day.formatted(.dateTime.day()))
                                .font(.system(size: 16)).fontWeight(.bold)
                                .foregroundColor(isSelected ? .white : .primary)
                        }
                        .frame(width: 36, height: 36)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) { viewModel.selectedDate = dayStart }
                    }
                }
            }
            .padding(.horizontal, 10)
            
            if isTaskListMinimized {
                if let startHour = dynamicStartHour {
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 0) {
                            TimeLabelsColumn(
                                startHour: startHour,
                                endHour: endHour,
                                hourHeight: hourHeight
                            )
                            
                            HStack(alignment: .top, spacing: 0) {
                                let week = viewModel.selectedDate.fetchWeek()
                                
                                ForEach(week, id: \.self) { day in
                                    let dayStart = day.startOfDay
                                    let tasksForDay = allTasks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: dayStart) }
                                    
                                    ZStack(alignment: .top) {
                                        TimelineTaskRenderer(
                                            tasks: tasksForDay,
                                            hourHeight: hourHeight,
                                            startHour: startHour,
                                            dayStart: dayStart
                                        )
                                    }
                                    .frame(height: CGFloat(endHour - startHour) * hourHeight)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .transition(.opacity)
                } else {
                    Spacer().frame(height: 50)
                }
                
            } else {
                HStack(spacing: 0) {
                    let week = viewModel.selectedDate.fetchWeek()
                    
                    ForEach(week, id: \.self) { day in
                        let dayStart = day.startOfDay
                        let tasksForDay = allTasks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: dayStart) }
                        
                        HorizontalDotsView(tasks: tasksForDay)
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring()) { viewModel.selectedDate = dayStart }
                            }
                    }
                }
                .padding(.horizontal, 10)
                .transition(.opacity)
            }
        }
        .padding(.bottom, 10)
        .background(Color(UIColor.systemGroupedBackground))
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    withAnimation(.snappy) {
                        if horizontalAmount < 0 {
                            if let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: viewModel.selectedDate) {
                                viewModel.selectedDate = nextWeek
                            }
                        } else {
                            if let prevWeek = Calendar.current.date(byAdding: .day, value: -7, to: viewModel.selectedDate) {
                                viewModel.selectedDate = prevWeek
                            }
                        }
                    }
                }
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isTaskListMinimized)
    }
}

struct TimeLabelsColumn: View {
    let startHour: Int
    let endHour: Int
    let hourHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            ForEach(startHour...endHour, id: \.self) { hour in
                let yPosition = CGFloat(hour - startHour) * hourHeight
                
                Text("\(hour)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
                    .frame(height: 12)
                    .offset(y: yPosition)
            }
        }
        .frame(width: 25, alignment: .trailing)
        .padding(.trailing, 4)
    }
}

struct TimelineTaskRenderer: View {
    let tasks: [AlignTask]
    let hourHeight: CGFloat
    let startHour: Int
    let dayStart: Date
    
    private let iconSize: CGFloat = 36
    
    func getYPosition(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let reference = calendar.date(
            byAdding: .hour,
            value: startHour,
            to: dayStart
        )!
        let minutesFromStart = date.timeIntervalSince(reference) / 60
        let pixelsPerMinute = hourHeight / 60
        return CGFloat(minutesFromStart) * pixelsPerMinute
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            let sortedTasks = tasks.sorted { $0.startTime < $1.startTime }
            
            ForEach(Array(sortedTasks.enumerated()), id: \.element.id) { index, task in
                if index < sortedTasks.count - 1 {
                    let nextTask = sortedTasks[index + 1]
                    let yPosTask1 = getYPosition(for: task.startTime)
                    let yPosTask2 = getYPosition(for: nextTask.startTime)
                    let lineStartY = yPosTask1 + (iconSize / 2)
                    let lineEndY = yPosTask2 - (iconSize / 2)
                    let lineHeight = lineEndY - lineStartY
                    
                    if lineHeight > 0 {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(task.colorName.toColor), Color(nextTask.colorName.toColor)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 2, height: lineHeight)
                            .offset(y: lineStartY)
                    }
                }
            }
            
            ForEach(sortedTasks) { task in
                ZStack {
                    Circle()
                        .fill(Color(task.colorName.toColor))
                        .frame(width: iconSize, height: iconSize)
                        .shadow(color: Color(task.colorName.toColor).opacity(0.3), radius: 3, y: 2)
                        .overlay(Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 1.5))
                    
                    Image(systemName: task.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(y: getYPosition(for: task.startTime) - (iconSize / 2))
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

struct HorizontalDotsView: View {
    let tasks: [AlignTask]
    var body: some View {
        HStack(spacing: -4) {
            if tasks.isEmpty {
                Circle().fill(.clear).frame(width: 14, height: 14)
            } else {
                ForEach(tasks.prefix(3)) { task in
                    ZStack {
                        Circle().fill(Color(task.colorName.toColor)).frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 1.5))
                        Image(systemName: task.icon).font(.system(size: 6, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
        }
    }
}
