import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var items: [FoodItem]

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
    
    private var weekTotals: (cal: Double, carb: Double, fat: Double, protein: Double) {
        guard let week = Calendar.current.date(byAdding: .day, value: -7, to: .now) else { return (0,0,0,0) }
        let weekItems = items.filter { $0.date >= week }
        return weekItems.reduce(into: (0,0,0,0)) { r,i in
            r.0 += i.calories
            r.1 += i.carbs
            r.2 += i.fat
            r.3 += i.protein
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Today Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Calories", value: "\(Int(todayTotals.cal))", color: .orange)
                        StatCard(title: "Carbs", value: "\(Int(todayTotals.carb))g", color: .blue)
                        StatCard(title: "Fat", value: "\(Int(todayTotals.fat))g", color: .purple) 
                        StatCard(title: "Protein", value: "\(Int(todayTotals.protein))g", color: .green)
                    }
                }
                
                Divider()
                
                // Week Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Calories", value: "\(Int(weekTotals.cal))", color: .orange)
                        StatCard(title: "Carbs", value: "\(Int(weekTotals.carb))g", color: .blue)
                        StatCard(title: "Fat", value: "\(Int(weekTotals.fat))g", color: .purple)
                        StatCard(title: "Protein", value: "\(Int(weekTotals.protein))g", color: .green)
                    }
                }
                
                Divider()
                
                // Quick Stats
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Stats")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Total Foods Logged")
                            Spacer()
                            Text("\(items.count)")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Average Daily Calories")
                            Spacer()
                            Text("\(averageDailyCalories)")
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    private var averageDailyCalories: Int {
        guard !items.isEmpty else { return 0 }
        let totalCals = items.reduce(0) { $0 + $1.calories }
        let days = Set(items.map { Calendar.current.startOfDay(for: $0.date) }).count
        return Int(totalCals / Double(max(days, 1)))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}