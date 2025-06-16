import SwiftUI
import SwiftData

@main
struct VibeCalAITestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FoodItem.self)
    }
}
