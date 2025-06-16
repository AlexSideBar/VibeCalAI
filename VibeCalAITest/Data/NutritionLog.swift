import SwiftUI
import Combine

@MainActor
final class NutritionLog: ObservableObject {
    @AppStorage("nutrition_items") private var stored: Data = Data()
    @Published var items: [FoodItem] = []

    init() {
        load()
    }

    func add(_ item: FoodItem) {
        items.append(item)
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    var todayTotals: (cal: Double, carb: Double, fat: Double, protein: Double) {
        let today = Calendar.current.startOfDay(for: .now)
        let todays = items.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
        return todays.reduce(into: (0,0,0,0)) { r,i in
            r.0 += i.calories
            r.1 += i.carbs
            r.2 += i.fat
            r.3 += i.protein
        }
    }

    // MARK: – Persistence
    private func save() {
        stored = (try? JSONEncoder().encode(items)) ?? Data()
    }
    private func load() {
        items = (try? JSONDecoder().decode([FoodItem].self, from: stored)) ?? []
    }
}
