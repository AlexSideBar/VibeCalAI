import SwiftUI
import SwiftData
import PhotosUI
import Combine

final class ScannerViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    @Published var image: UIImage?
    @Published var isProcessing = false
    @Published var detected: FoodItem?
    @Published var error: String?

    private let service = FoodAnalysisService()
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    @MainActor
    func processSelection() {
        guard let item = selectedItem else { return }
        Task {
            isProcessing = true
            defer { isProcessing = false }
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let ui = UIImage(data: data) {
                    image = ui
                    if let food = try await service.analyze(image: ui) {
                        detected = food
                        modelContext?.insert(food)
                    } else {
                        error = "Couldn't understand food."
                    }
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
