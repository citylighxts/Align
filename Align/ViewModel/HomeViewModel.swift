import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var selectedDate: Date = Date().startOfDay
    @Published var showAddSheet = false
    @Published var taskToEdit: AlignTask?
    
    var calendarPages: [Date] {
        let calendar = Calendar.current
        let today = Date().startOfDay
        let startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        let endDate = calendar.date(byAdding: .year, value: 1, to: today)!
        
        var dates: [Date] = []
        var currentDate = startDate
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    func jumpToToday() {
        selectedDate = Date().startOfDay
    }
}
