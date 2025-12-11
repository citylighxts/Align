import Foundation
import SwiftData

@Model
class AlignTask {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var icon: String
    var colorName: String
    var isCompleted: Bool = false
    
    init(title: String, startTime: Date, endTime: Date, icon: String, colorName: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.icon = icon
        self.colorName = colorName
        self.isCompleted = isCompleted
    }
}
