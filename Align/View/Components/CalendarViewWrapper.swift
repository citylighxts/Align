import SwiftUI
import UIKit
import SwiftData

struct CalendarViewWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date
    var tasks: [AlignTask]
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        
        calendarView.delegate = context.coordinator
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.tasks = tasks
        
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            selection.setSelected(dateComponents, animated: true)
        }
        
        DispatchQueue.main.async {
            let monthYear = uiView.visibleDateComponents
            let calendar = uiView.calendar
            
            guard let date = calendar.date(from: monthYear),
                  let range = calendar.range(of: .day, in: .month, for: date) else { return }
            
            let datesToReload = range.map { day -> DateComponents in
                var components = monthYear
                components.day = day
                return components
            }
            
            uiView.reloadDecorations(forDateComponents: datesToReload, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, tasks: tasks)
    }
    
        class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
            var parent: CalendarViewWrapper
            var tasks: [AlignTask]
            
            init(parent: CalendarViewWrapper, tasks: [AlignTask]) {
                self.parent = parent
                self.tasks = tasks
            }
            
            func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
                guard let date = Calendar.current.date(from: dateComponents) else { return nil }
                
                let tasksForDay = tasks.filter {
                    Calendar.current.isDate($0.startTime, inSameDayAs: date)
                }
                
                if tasksForDay.isEmpty { return nil }
                
                return .customView {
                    let wrapperView = UIView()
                    wrapperView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let stackView = UIStackView()
                    stackView.axis = .horizontal
                    stackView.alignment = .center
                    stackView.distribution = .fill
                    stackView.spacing = -4
                    stackView.translatesAutoresizingMaskIntoConstraints = false
                    
                    wrapperView.addSubview(stackView)
                    
                    for task in tasksForDay.prefix(3) {
                        let containerSize: CGFloat = 14
                        
                        let container = UIView()
                        container.translatesAutoresizingMaskIntoConstraints = false
                        container.backgroundColor = UIColor(task.colorName.toColor)
                        
                        container.layer.cornerRadius = containerSize / 2
                        container.layer.borderWidth = 1.5
                        container.layer.borderColor = UIColor.systemBackground.cgColor
                        container.clipsToBounds = true
                        
                        let config = UIImage.SymbolConfiguration(pointSize: 4, weight: .bold)
                        let image = UIImage(systemName: task.icon, withConfiguration: config)?
                            .withTintColor(.white, renderingMode: .alwaysOriginal)
                        
                        let imageView = UIImageView(image: image)
                        imageView.translatesAutoresizingMaskIntoConstraints = false
                        imageView.contentMode = .center
                        
                        container.addSubview(imageView)
                        
                        NSLayoutConstraint.activate([
                            container.widthAnchor.constraint(equalToConstant: containerSize),
                            container.heightAnchor.constraint(equalToConstant: containerSize),
                            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
                        ])
                        
                        stackView.addArrangedSubview(container)
                    }
                    
                    NSLayoutConstraint.activate([
                        stackView.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor),
                        stackView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
                        
                        wrapperView.heightAnchor.constraint(equalToConstant: 14),
                        
                        wrapperView.widthAnchor.constraint(greaterThanOrEqualToConstant: 45),
                        
                        wrapperView.widthAnchor.constraint(greaterThanOrEqualTo: stackView.widthAnchor)
                    ])
                    
                    return wrapperView
                }
            }
            
            func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
                guard let dateComponents = dateComponents,
                      let date = Calendar.current.date(from: dateComponents) else { return }
                
                withAnimation {
                    parent.selectedDate = date
                }
            }
        }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlignTask.self, configurations: config)
    
    let task = AlignTask(title: "Test", startTime: Date(), endTime: Date(), icon: "star.fill", colorName: "Purple")
    container.mainContext.insert(task)

    return ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        CalendarViewWrapper(selectedDate: .constant(Date()), tasks: [task])
            .frame(height: 400)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(.white))
            .padding()
    }
    .modelContainer(container)
}
