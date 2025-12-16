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
        
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        selection.selectedDate = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.tasks = tasks
        
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let currentSelected = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            if selection.selectedDate != currentSelected {
                selection.setSelected(currentSelected, animated: true)
            }
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        uiView.reloadDecorations(forDateComponents: [dateComponents], animated: true)
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
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents,
                  let date = Calendar.current.date(from: dateComponents) else { return }
            
            withAnimation {
                parent.selectedDate = date
            }
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            
            let tasksForDay = tasks.filter {
                Calendar.current.isDate($0.startTime, inSameDayAs: date)
            }
            
            if tasksForDay.isEmpty { return nil }
            
            return .customView {
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .center
                stackView.distribution = .fill
                stackView.spacing = -6
                stackView.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.addSubview(stackView)
                
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    containerView.heightAnchor.constraint(equalToConstant: 24)
                ])
                
                for task in tasksForDay.prefix(3) {
                    let iconSize: CGFloat = 18
                    
                    let circleView = UIView()
                    circleView.translatesAutoresizingMaskIntoConstraints = false
                    circleView.backgroundColor = UIColor(task.colorName.toColor)
                    circleView.layer.cornerRadius = iconSize / 2
                    
                    circleView.layer.borderColor = UIColor.systemBackground.cgColor
                    circleView.layer.borderWidth = 2.0
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
                    let image = UIImage(systemName: task.icon, withConfiguration: config)?
                        .withTintColor(.white, renderingMode: .alwaysOriginal)
                    
                    let imageView = UIImageView(image: image)
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    imageView.contentMode = .scaleAspectFit
                    
                    circleView.addSubview(imageView)
                    
                    NSLayoutConstraint.activate([
                        circleView.widthAnchor.constraint(equalToConstant: iconSize),
                        circleView.heightAnchor.constraint(equalToConstant: iconSize),
                        
                        imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
                        imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
                    ])
                    
                    stackView.addArrangedSubview(circleView)
                }
                
                return containerView
            }
        }
    }
}
