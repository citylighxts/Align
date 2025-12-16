import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var selectedDate: Date = Date().startOfDay
    @Published var showAddSheet = false
    @Published var taskToEdit: AlignTask?
    @Published var initialStartTime: Date?
    
    lazy var calendarPages: [Date] = generateCalendarPages()
    
    private func generateCalendarPages() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        let currentYear = calendar.component(.year, from: today)
        
        var startComponents = DateComponents()
        startComponents.year = currentYear - 1
        startComponents.month = 1
        startComponents.day = 1
        guard let startDate = calendar.date(from: startComponents) else { return [] }
        
        var endComponents = DateComponents()
        endComponents.year = currentYear + 1
        endComponents.month = 12
        endComponents.day = 31
        guard let endDate = calendar.date(from: endComponents) else { return [] }
        
        var dates: [Date] = []
        var currentDate = startDate
        
        let finalDate = calendar.startOfDay(for: endDate)
        
        while calendar.startOfDay(for: currentDate) <= finalDate {
            dates.append(currentDate)
            
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }
    
    func jumpToToday() {
        withAnimation {
            selectedDate = Date().startOfDay
        }
    }
}
