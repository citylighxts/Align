import SwiftUI
import SwiftData

struct HomeHeaderView: View {
    @ObservedObject var viewModel: HomeViewModel
    var allTasks: [AlignTask]
    @Binding var showCalendarPicker: Bool
    var animationNamespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    withAnimation(.spring()) {
                        showCalendarPicker = true
                    }
                }) {
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    let week = viewModel.selectedDate.fetchWeek()
                    ForEach(week, id: \.self) { day in
                        let dayStart = day.startOfDay
                        let isSelected = dayStart == viewModel.selectedDate
                        let tasksForDay = allTasks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: dayStart) }
                        
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
                            
                            HStack(spacing: -4) {
                                if tasksForDay.isEmpty {
                                    Circle().fill(.clear).frame(width: 14, height: 14)
                                } else {
                                    ForEach(tasksForDay.prefix(3)) { task in
                                        ZStack {
                                            Circle().fill(Color(task.colorName.toColor)).frame(width: 14, height: 14)
                                                .overlay(Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 1.5))
                                            Image(systemName: task.icon).font(.system(size: 6, weight: .bold)).foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .frame(height: 14)
                        }
                        .padding(.vertical, 10).padding(.horizontal, 5)
                        .onTapGesture { withAnimation(.spring()) { viewModel.selectedDate = dayStart } }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}
