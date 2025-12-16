import SwiftUI

struct CustomCalendarBottomPanel: View {
    @Binding var selectedDate: Date
    var allTasks: [AlignTask]
    var onClose: () -> Void
    
    @State private var currentMonth: Date = Date()
    @State private var slideEdge: Edge = .trailing
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Spacer()
                
                Button("Jump to Today") {
                    let today = Date()
                    let calendar = Calendar.current
                    
                    if calendar.isDate(currentMonth, equalTo: today, toGranularity: .month) {
                        withAnimation {
                            selectedDate = today
                        }
                    } else {
                        slideEdge = currentMonth > today ? .leading : .trailing
                        
                        withAnimation {
                            selectedDate = today
                            currentMonth = today
                        }
                    }
                }
                .font(.footnote.bold())
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            HStack {
                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.title3.bold())
                    .animation(.none, value: currentMonth)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            ZStack {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(currentMonth.fetchAllDaysInMonth(), id: \.self) { date in
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let isSameMonth = Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        let tasksForDay = getTasks(for: date)
                        
                        Button(action: {
                            withAnimation {
                                selectedDate = date
                                if !isSameMonth {
                                    slideEdge = date < currentMonth ? .leading : .trailing
                                    currentMonth = date
                                }
                            }
                        }) {
                            VStack(spacing: 6) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isSelected ? .white : (isSameMonth ? .primary : .gray.opacity(0.4)))
                                    .frame(width: 32, height: 32)
                                    .background(
                                        ZStack {
                                            if isSelected {
                                                Circle().fill(Color.blue)
                                                    .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
                                            }
                                        }
                                    )
                                
                                if !tasksForDay.isEmpty {
                                    HStack(spacing: -6) {
                                        ForEach(Array(tasksForDay.prefix(3).enumerated()), id: \.element.id) { index, task in
                                            ZStack {
                                                Circle()
                                                    .fill(Color(task.colorName.toColor))
                                                    .frame(width: 16, height: 16)
                                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                                
                                                Image(systemName: task.icon)
                                                    .font(.system(size: 8, weight: .black))
                                                    .foregroundColor(.white)
                                            }
                                            .zIndex(Double(index))
                                        }
                                    }
                                    .frame(height: 16)
                                } else {
                                    Color.clear.frame(height: 16)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .id(currentMonth)
                .transition(.asymmetric(
                    insertion: .move(edge: slideEdge),
                    removal: .move(edge: slideEdge == .leading ? .trailing : .leading)
                ))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 { changeMonth(by: 1) }
                        else if value.translation.width > 0 { changeMonth(by: -1) }
                    }
            )
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 24))
        .shadow(radius: 10)
        .onAppear { currentMonth = selectedDate }
    }
    
    private func changeMonth(by value: Int) {
        slideEdge = value > 0 ? .trailing : .leading
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMonth = newMonth
            }
        }
    }
    
    private func getTasks(for date: Date) -> [AlignTask] {
        allTasks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: date) }
    }
}
