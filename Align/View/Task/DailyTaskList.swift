import SwiftUI
import SwiftData

struct DailyTaskList: View {
    @Query private var tasks: [AlignTask]
    @Environment(\.modelContext) var context
    
    let selectedDate: Date
    let onEdit: (AlignTask) -> Void
    let onAddGap: (Date) -> Void
    
    init(date: Date, onEdit: @escaping (AlignTask) -> Void, onAddGap: @escaping (Date) -> Void) {
        self.selectedDate = date
        self.onEdit = onEdit
        self.onAddGap = onAddGap
        
        let start = date.startOfDay
        let end = date.endOfDay
        
        _tasks = Query(filter: #Predicate { task in
            task.startTime >= start && task.startTime <= end
        }, sort: \.startTime)
    }
    
    private func gapBetween(_ current: AlignTask, _ next: AlignTask) -> TimeInterval? {
        let gap = next.startTime.timeIntervalSince(current.endTime)
        return gap >= 4 * 3600 ? gap : nil
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                if tasks.isEmpty {
                    ContentUnavailableView {
                        Label("Free Day", systemImage: "calendar")
                    } description: {
                        Text("No tasks scheduled for this day.")
                    }
                    .padding(.top, 60)
                    .opacity(0.6)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                            VStack(spacing: 0) {

                                GridTaskCard(
                                    task: task,
                                    isFirst: index == 0,
                                    isLast: index == tasks.count - 1
                                )
                                .onTapGesture { onEdit(task) }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        context.delete(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .id(task.id)

                                if index < tasks.count - 1 {
                                    let nextTask = tasks[index + 1]
                                    
                                    if let gap = gapBetween(task, nextTask) {
                                        GapIndicatorView(duration: gap) {
                                            onAddGap(task.endTime)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .onAppear {
                if let firstUpcoming = tasks.first(where: { $0.endTime > Date() }) {
                    withAnimation {
                        scrollProxy.scrollTo(firstUpcoming.id, anchor: .top)
                    }
                }
            }
        }
    }
}
