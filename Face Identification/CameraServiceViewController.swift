//
//  CameraService.swift
//  Face Identification
//
//  Created by Daniel Coburn on 2/25/24.
//

import UIKit
import SwiftUI
import AVFoundation

class CameraServiceViewController: UIViewController {
    // MARK: - PROPERTIES
    
    // getting permision for camera
    private var permissionGranted = false
    
    // accessing camera
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    // drawing camera info
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil
    
    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async {
            guard self.permissionGranted else {
                return
            }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: - check permission
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    // MARK: - request permission
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    // MARK: - setup capture session
    func setupCaptureSession() {
        // access for camera
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else { return }
        guard let videoDeviceIn = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        guard captureSession.canAddInput(videoDeviceIn) else { return }
        captureSession.addInput(videoDeviceIn)
        
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        previewLayer.connection?.videoRotationAngle = CGFloat(90)
        
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
}


struct HostedCameraServiceViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return CameraServiceViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
