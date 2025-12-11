import SwiftUI
import SwiftData

@main
struct AlignApp: App {
    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: AlignTask.self)
    }
}
