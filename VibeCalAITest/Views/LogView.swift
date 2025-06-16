import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.date, order: .reverse) private var items: [FoodItem]
    @State private var showingAdd = false

    private var todayTotals: (cal: Double, carb: Double, fat: Double, protein: Double) {
        let today = Calendar.current.startOfDay(for: .now)
        let todayItems = items.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
        return todayItems.reduce(into: (0,0,0,0)) { r,i in
            r.0 += i.calories
            r.1 += i.carbs
            r.2 += i.fat
            r.3 += i.protein
        }
    }

    var body: some View {
        List {
            // Today's totals section
            Section {
                VStack(spacing: 16) {
                    HStack {
                        VStack {
                            Text("\(Int(todayTotals.cal))")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Calories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(Int(todayTotals.carb))g")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Carbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(Int(todayTotals.fat))g")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Fat")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(Int(todayTotals.protein))g")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Protein")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                HStack {
                    Text("Today's Totals")
                    Spacer()
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }

            // Food items
            if items.isEmpty {
                ContentUnavailableView(
                    "No Foods Logged",
                    systemImage: "fork.knife",
                    description: Text("Start by scanning food with the camera or adding manually")
                )
            } else {
                Section("Recent Foods") {
                    ForEach(items.prefix(20)) { item in
                        FoodItemRow(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddManualEntryView()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(item.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                MacroChip(value: Int(item.calories), unit: "cal", color: .orange)
                MacroChip(value: Int(item.carbs), unit: "carb", color: .blue)
                MacroChip(value: Int(item.fat), unit: "fat", color: .purple)
                MacroChip(value: Int(item.protein), unit: "pro", color: .green)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct MacroChip: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.medium)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}
