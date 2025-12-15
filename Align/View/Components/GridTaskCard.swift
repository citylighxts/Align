import SwiftUI

struct GridTaskCard: View {
    @Bindable var task: AlignTask
    let hourHeight: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            
            Text(task.startTime.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
            
            ZStack {
                Circle()
                    .fill(task.colorName.toColor.gradient)
                
                Image(systemName: task.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 32, height: 32)
            .scaleEffect(1.0)
            .animation(.spring(), value: task.isCompleted)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)
                
                Text("until \(task.endTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring()) {
                    task.isCompleted.toggle()
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? .green : .gray.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

#Preview {
    let coffeeTask = AlignTask(
        title: "Coffee Break",
        startTime: Date(),
        endTime: Date().addingTimeInterval(1800),
        icon: "cup.and.saucer.fill",
        colorName: "Orange"
    )
    VStack {
        GridTaskCard(task: coffeeTask, hourHeight: 0)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
