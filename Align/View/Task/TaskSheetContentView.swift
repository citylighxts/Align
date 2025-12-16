import SwiftUI

struct TaskSheetContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
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
            
            Button(action: { viewModel.showAddSheet = true }) {
                Image(systemName: "plus")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue.gradient)
                    .clipShape(Circle())
                    .shadow(radius: 5, y: 5)
            }
            .padding(25)
        }
    }
}
