import SwiftUI

struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        return path
    }
}

struct GapIndicatorView: View {
    let duration: TimeInterval
    let action: () -> Void
    
    private var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m Free"
        } else if hours > 0 {
            return "\(hours)h Free"
        } else {
            return "\(minutes)m Free"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            
            Spacer()
                .frame(width: 50)
            
            DottedLine()
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundColor(Color.gray.opacity(0.3))
                .frame(width: 32)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(durationString)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Button(action: action) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add Task")
                    }
                    .font(.caption.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                }
            }
            .padding(.vertical, 12)
            .padding(.leading, 4)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .fixedSize(horizontal: false, vertical: true)
    }
}
