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
    
    // Fungsi untuk mendapatkan semua tanggal dalam bulan tersebut untuk keperluan Grid
    func fetchAllDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        
        // 1. Dapatkan tanggal 1 bulan ini
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        
        // 2. Dapatkan hari dalam seminggu untuk tanggal 1 (Misal: Senin = 2, Minggu = 1)
        // Kita butuh offset untuk mengisi hari dari bulan sebelumnya
        let startOfWeek = calendar.component(.weekday, from: startOfMonth)
        
        // 3. Hitung tanggal mundur ke hari Minggu/Senin pertama di grid (Padding Awal)
        // (startOfWeek - 1) asumsi kalender mulai hari Minggu. Sesuaikan jika mulai Senin.
        // Jika startOfWeek = 1 (Minggu), offsetnya 0. Jika 2 (Senin), offsetnya 1.
        let offsetDays = startOfWeek - calendar.firstWeekday
        let adjustedOffset = offsetDays < 0 ? offsetDays + 7 : offsetDays // Handle wrap around
        
        guard let startOfGrid = calendar.date(byAdding: .day, value: -adjustedOffset, to: startOfMonth) else { return [] }
        
        // 4. Generate 42 hari (6 baris x 7 kolom) agar grid selalu rapi & fix height
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
        // Mencari tanggal awal minggu (Minggu/Senin tergantung region)
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else {
            return []
        }
        
        var dates: [Date] = []
        // Loop 7 hari ke depan dari startOfWeek
        (0..<7).forEach { day in
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }
}
