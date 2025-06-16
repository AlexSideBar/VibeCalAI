import SwiftUI
import SwiftData

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var detectedFood: FoodItem?
    @State private var error: String?
    
    private let service = FoodAnalysisService()

    var body: some View {
        NavigationStack {
            VStack {
                if let image = capturedImage {
                    // Show captured image and results
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                    
                    if isProcessing {
                        ProgressView("Analyzing food...")
                            .padding()
                    } else if let food = detectedFood {
                        NutritionResultView(food: food)
                            .padding()
                    } else if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button("Retake Photo") {
                        resetState()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                } else {
                    // Show camera picker
                    ImagePicker(selectedImage: $capturedImage)
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("Scan Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                if detectedFood != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                processImage(image)
            }
        }
    }
    
    private func resetState() {
        capturedImage = nil
        detectedFood = nil
        error = nil
        isProcessing = false
    }
    
    private func processImage(_ image: UIImage) {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                if let food = try await service.analyze(image: image) {
                    detectedFood = food
                    modelContext.insert(food)
                } else {
                    error = "Could not identify food in image"
                }
            } catch {
                self.error = "Error analyzing image: \(error.localizedDescription)"
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Handle cancellation if needed
        }
    }
}

struct NutritionResultView: View {
    let food: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(food.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NutritionCard(title: "Calories", value: "\(Int(food.calories))", color: .orange)
                NutritionCard(title: "Carbs", value: "\(Int(food.carbs))g", color: .blue)
                NutritionCard(title: "Fat", value: "\(Int(food.fat))g", color: .purple)
                NutritionCard(title: "Protein", value: "\(Int(food.protein))g", color: .green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NutritionCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
