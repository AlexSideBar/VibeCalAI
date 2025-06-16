import SwiftUI
import SwiftData
import AVFoundation
import Combine

final class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isProcessing = false
    @Published var detectedFood: FoodItem?
    @Published var error: String?
    
    private let service = FoodAnalysisService()
    private var modelContext: ModelContext?
    internal let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func setupCamera() {
        guard captureSession.inputs.isEmpty else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            error = "Cannot access camera"
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @MainActor
    private func processImage(_ image: UIImage) {
        capturedImage = image
        
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                if let food = try await service.analyze(image: image) {
                    detectedFood = food
                    modelContext?.insert(food)
                } else {
                    error = "Could not identify food in image"
                }
            } catch {
                self.error = "Error analyzing image: \(error.localizedDescription)"
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.error = "Capture error: \(error.localizedDescription)"
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.error = "Could not process captured image"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.processImage(image)
        }
    }
}
