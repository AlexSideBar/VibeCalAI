import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.date, order: .reverse) private var items: [FoodItem]
    @Binding var showingAdd: Bool

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
        ScrollView {
            LazyVStack(spacing: 16) {
                Text("Today's Totals")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                GlassEffectContainer(spacing: 12) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        MacroCard(value: "\(Int(todayTotals.cal))", label: "Calories", color: .orange)
                        MacroCard(value: "\(Int(todayTotals.carb))g", label: "Carbs", color: .blue)
                        MacroCard(value: "\(Int(todayTotals.fat))g", label: "Fat", color: .purple)
                        MacroCard(value: "\(Int(todayTotals.protein))g", label: "Protein", color: .green)
                    }
                    .padding(.horizontal)
                }
                
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Foods Logged",
                        systemImage: "fork.knife",
                        description: Text("Start by scanning food with the camera")
                    )
                    .padding(.top, 60)
                } else {
                    Text("Recent Foods")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    GlassEffectContainer(spacing: 12) {
                        LazyVStack(spacing: 12) {
                            ForEach(items.prefix(20)) { item in
                                FoodItemRow(item: item, onDelete: {
                                    deleteItem(item)
                                })
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func deleteItem(_ item: FoodItem) {
        modelContext.delete(item)
    }
}

struct MacroCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundStyle(.white)
        .glassEffect(.regular.tint(color))
    }
}

struct FoodItemRow: View {
    let item: FoodItem
    let onDelete: () -> Void
    @State private var offset = CGSize.zero
    @State private var showingDeleteButton = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                    Text(item.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    MacroChip(value: Int(item.calories), unit: "cal", color: .orange)
                    MacroChip(value: Int(item.carbs), unit: "carb", color: .blue)
                    MacroChip(value: Int(item.fat), unit: "fat", color: .purple)
                    MacroChip(value: Int(item.protein), unit: "pro", color: .green)
                    Spacer()
                }
            }
            .padding()
            .glassEffect()
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = value.translation
                            showingDeleteButton = offset.width < -50
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width < -100 {
                                onDelete()
                            } else if value.translation.width < -50 {
                                offset = CGSize(width: -80, height: 0)
                            } else {
                                offset = .zero
                                showingDeleteButton = false
                            }
                        }
                    }
            )
            
            if showingDeleteButton {
                Button(action: {
                    withAnimation(.spring()) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .onTapGesture {
            if showingDeleteButton {
                withAnimation(.spring()) {
                    offset = .zero
                    showingDeleteButton = false
                }
            }
        }
    }
}

struct MacroChip: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(value)")
                .fontWeight(.medium)
            Text(unit)
                .foregroundColor(.secondary)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
        .foregroundColor(color)
    }
}
