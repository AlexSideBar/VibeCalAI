import SwiftUI
import SwiftData
import PhotosUI

struct ScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = ScannerViewModel()

    var body: some View {
        VStack {
            if let img = vm.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
            }

            if vm.isProcessing {
                ProgressView("Analyzing…")
            } else if let food = vm.detected {
                NutritionSummary(food: food)
            } else if let err = vm.error {
                Text(err).foregroundColor(.red)
            }

            PhotosPicker(selection: $vm.selectedItem,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label("Pick or Shoot", systemImage: "camera")
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        .onAppear {
            vm.setModelContext(modelContext)
        }
        .onChange(of: vm.selectedItem) { _ in
            vm.processSelection()
        }
        .navigationTitle("Scan Food")
    }
}

private struct NutritionSummary: View {
    let food: FoodItem
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(food.name).font(.title3).bold()
            HStack {
                Metric("Cal", value: food.calories)
                Metric("Carb", value: food.carbs)
                Metric("Fat", value: food.fat)
                Metric("Pro", value: food.protein)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func Metric(_ title: String, value: Double) -> some View {
        VStack {
            Text("\(Int(value))")
                .font(.headline)
            Text(title).font(.caption2)
        }
        .frame(maxWidth: .infinity)
    }
}
