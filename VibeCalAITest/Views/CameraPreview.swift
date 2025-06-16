import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let vm: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: vm.captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add capture button
        let captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        captureButton.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 40
        captureButton.layer.borderWidth = 5
        captureButton.layer.borderColor = UIColor.systemBlue.cgColor
        captureButton.addTarget(context.coordinator, action: #selector(Coordinator.capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        
        vm.setupCamera()
        vm.startSession()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm: vm)
    }
    
    class Coordinator: NSObject {
        let vm: CameraViewModel
        
        init(vm: CameraViewModel) {
            self.vm = vm
        }
        
        @objc func capturePhoto() {
            vm.capturePhoto()
        }
    }
}
