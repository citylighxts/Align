import SwiftUI
import SwiftData

struct CustomCalendarBottomPanel: View {
    @Binding var selectedDate: Date
    var allTasks: [AlignTask]
    var onClose: () -> Void
    
    @State private var offsetY: CGFloat = 0
    
    private var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                
                CalendarViewWrapper(selectedDate: $selectedDate, tasks: allTasks)
                    .frame(height: 380)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    if !isSelectedDateToday {
                        Button("Today") {
                            withAnimation { selectedDate = Date() }
                        }
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
                .padding(.bottom, 10)
                
                .frame(minWidth: 140, alignment: .trailing)
                .background(Color.white)
                .shadow(color: .white, radius: 8, x: -10, y: 0)
                
                .padding(.top, 20)
                .padding(.trailing, 16)
            }
            
            Spacer().frame(height: 20)
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 28))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .edgesIgnoringSafeArea(.bottom)
        
        .offset(y: offsetY)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        offsetY = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        onClose()
                    } else {
                        withAnimation(.spring()) {
                            offsetY = 0
                        }
                    }
                }
        )
    }
}
