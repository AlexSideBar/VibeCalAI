import SwiftUI
import SwiftData

struct AddManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var calories = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var protein = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Food name", text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Food Item")
                }
                
                Section {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                        Text("calories")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "c.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        TextField("0", text: $carbs)
                            .keyboardType(.numberPad)
                        Text("g carbs")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "f.circle.fill")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        TextField("0", text: $fat)
                            .keyboardType(.numberPad)
                        Text("g fat")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "p.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        TextField("0", text: $protein)
                            .keyboardType(.numberPad)
                        Text("g protein")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Nutrition Facts")
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let item = FoodItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            calories: Double(calories) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            protein: Double(protein) ?? 0
        )
        modelContext.insert(item)
        dismiss()
    }
}
