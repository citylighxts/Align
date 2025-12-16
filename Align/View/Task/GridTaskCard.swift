import SwiftUI

struct GridTaskCard: View {
    @Bindable var task: AlignTask
    var isFirst: Bool
    var isLast: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            
            Text(task.startTime.formatted(date: .omitted, time: .shortened))
                .font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
                .frame(width: 50, alignment: .trailing)
            
            ZStack {
                VStack(spacing: 0) {
                    if !isFirst {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 2).frame(maxHeight: .infinity)
                    } else {
                        Color.clear.frame(width: 2).frame(maxHeight: .infinity)
                    }
                    if !isLast {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 2).frame(maxHeight: .infinity)
                    } else {
                        Color.clear.frame(width: 2).frame(maxHeight: .infinity)
                    }
                }
                
                ZStack {
                    Circle().fill(task.colorName.toColor.gradient)
                    Image(systemName: task.icon).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                }
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color(UIColor.systemGroupedBackground)).frame(width: 38, height: 38))
                .scaleEffect(1.0)
            }
            .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title).font(.system(size: 16, weight: .bold))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)
                Text("until \(task.endTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2).foregroundColor(.secondary)
            }
            .padding(.leading, 4)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) { task.isCompleted.toggle() }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? .green : .gray.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 0)
        .frame(minHeight: 70)
    }
}
