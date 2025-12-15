import SwiftUI
import SwiftData

struct CalendarSheetView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    @Query private var tasks: [AlignTask]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            VStack {
                CalendarViewWrapper(selectedDate: $selectedDate, tasks: tasks)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .frame(height: 400)
                
                Spacer()
            }
            
            Button("Today") {
                withAnimation {
                    selectedDate = Date()
                }
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.blue)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    .background(Capsule().fill(Color(UIColor.systemBackground).opacity(0.8)))
            )
            .padding(.top, 30)
            .padding(.trailing, 95)
            
        }
        .presentationDetents([.medium, .fraction(0.6)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    return CalendarSheetView(selectedDate: .constant(Date()))
        .modelContainer(container)
}
