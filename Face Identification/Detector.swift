//
//  Detector.swift
//  Face Identification
//
//  Created by Daniel Coburn on 3/2/24.
//

import UIKit
import AVFoundation
import Vision

extension CameraServiceViewController {
    
    func setupDetector() {
        let modelURL = Bundle.main.url(forResource: "YOLOv3TinyInt8LUT", withExtension: "mlmodelc")
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL!))
            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            recognitions.imageCropAndScaleOption = .scaleFill
            self.requests = [recognitions]
        } catch let error {
            print(error)
        }
    }
    
    func setupLayers() {
        detectionLayer = CALayer()
        detectionLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        self.view.layer.addSublayer(detectionLayer)
    }
    
    func updateLayers() {
        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func extractDetections(_ results: [VNObservation]) {
        detectionLayer.sublayers = nil // clear past detections
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            print((observation.description) + " " + "\(observation.confidence)")
            // coordinate transformations
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
            let transformedBounds = CGRect(
                x: objectBounds.minX,
                y: screenRect.size.height - objectBounds.minY,
                width: objectBounds.maxX - objectBounds.minX,
                height: objectBounds.maxY - objectBounds.minY
            )
            //print("bounds \(transformedBounds)")
            
            let boxLayer = self.drawBoundingBox(transformedBounds)
            detectionLayer.addSublayer(boxLayer)
        }
    }
    
    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
        //print("drawing \(bounds)")
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 3.0
        boxLayer.borderColor = CGColor.init(red: 1, green: 1, blue: 1, alpha: 1.0)
        boxLayer.cornerRadius = 4
        return boxLayer
    }
    
    func addPoint() {
        let layer = CALayer()
        //layer.frame = (282.50244140625, -8.0361328125, 106.0693359375, 451.259765625)
    }
    
    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            if let results = request.results {
                self.extractDetections(results)
            }
        })
    }
}
