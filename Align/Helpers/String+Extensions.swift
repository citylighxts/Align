import SwiftUI

extension String {
    var toColor: Color {
        switch self {
        case "Purple": return .indigo
        case "Pink": return .pink
        case "Teal": return .teal
        case "Orange": return .orange
        case "Blue": return .blue
        case "Gray": return .gray
        default: return .indigo
        }
    }
}
