import SwiftUI

extension String {
    var toColor: Color {
        switch self {
        case "Orange": return .orange
        case "Blue": return .blue
        case "Purple": return .purple
        case "Pink": return .pink
        case "Teal": return .teal
        case "Red": return .red
        case "Green": return .green
        case "Yellow": return .yellow
        default: return .blue
        }
    }
}
