import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func fetchAllDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        
        let startOfWeek = calendar.component(.weekday, from: startOfMonth)
        
        let offsetDays = startOfWeek - calendar.firstWeekday
        let adjustedOffset = offsetDays < 0 ? offsetDays + 7 : offsetDays
        
        guard let startOfGrid = calendar.date(byAdding: .day, value: -adjustedOffset, to: startOfMonth) else { return [] }
        
        var days: [Date] = []
        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfGrid) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func fetchWeek() -> [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else {
            return []
        }
        
        var dates: [Date] = []
        (0..<7).forEach { day in
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }
}
