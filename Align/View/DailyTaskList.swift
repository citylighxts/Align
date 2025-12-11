import SwiftUI
import SwiftData

struct DailyTaskList: View {
    @Query private var tasks: [AlignTask]
    @Environment(\.modelContext) var context
    
    let selectedDate: Date
    let onEdit: (AlignTask) -> Void
    
    init(date: Date, onEdit: @escaping (AlignTask) -> Void) {
        self.selectedDate = date
        self.onEdit = onEdit
        
        let start = date.startOfDay
        let end = date.endOfDay
        
        _tasks = Query(filter: #Predicate { task in
            task.startTime >= start && task.startTime <= end
        }, sort: \.startTime)
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                if tasks.isEmpty {
                    ContentUnavailableView {
                        Label("Free Day", systemImage: "sparkles")
                    } description: {
                        Text("No tasks scheduled for this day.")
                    }
                    .padding(.top, 60)
                    .opacity(0.6)
                } else {
                    ZStack(alignment: .topLeading) {
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 2)
                            .padding(.leading, 88)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        
                        LazyVStack(spacing: 20) {
                            ForEach(tasks) { task in
                                GridTaskCard(task: task, hourHeight: 0)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .onTapGesture { onEdit(task) }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            NotificationManager.shared.cancelNotification(for: task)
                                            context.delete(task)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .id(task.id)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .onAppear {
                if let firstUpcomingTask = tasks.first(where: { $0.endTime > Date() }) {
                    withAnimation {
                        scrollProxy.scrollTo(firstUpcomingTask.id, anchor: .top)
                    }
                }
            }
        }
    }
}
