/*
See the APPLE-LICENSE.txt file for this sample’s licensing information.

Abstract: The app's main view controller object.
*/

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {

    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private let drawOverlay = CAShapeLayer()
    private let drawPath = UIBezierPath()
    // private var evidenceBuffer = [PeakDetectionAlgorithm.PointsPair]()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private var detection = (120.0,4,1)
    private var beatBuffer = BeatBuffer(capacity: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawOverlay.frame = view.layer.bounds
        drawOverlay.lineWidth = 5
        drawOverlay.backgroundColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.5).cgColor
        drawOverlay.strokeColor = #colorLiteral(red: 0.6, green: 0.1, blue: 0.3, alpha: 1).cgColor
        drawOverlay.fillColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0).cgColor
        drawOverlay.lineCap = .round
        view.layer.addSublayer(drawOverlay)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
}
    
    func processPoint(point: CGPoint?) {
        // Check that we have both points.
        guard let newPoint = point else {
            // If there were no observations for more than 3 seconds reset peak buffer.
            if Date().timeIntervalSince(lastObservationTimestamp) > 3 {
                beatBuffer.clear()
            }
            cameraView.showPoints(color: .clear, point: point ?? CGPoint(x: -1,y: -1))
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let wristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: newPoint)
        
        // Add new points to peak buffer
        let newBufferPoint = BufferPoint(point: newPoint, time: lastObservationTimestamp)
        beatBuffer.addPoint(point: newBufferPoint)
        
}
    
}

// modified from https://developer.apple.com/documentation/vision/detecting-human-body-poses-in-images with suggestions from Google Gemini
func processObservation(_ observation: VNHumanHandPoseObservation) -> CGPoint? {
    
    // Retrieve all recognized points from the observation.
    guard let recognizedPoints = try? observation.recognizedPoints(.all) else { return nil }
    
    // Get the specific wrist point.
    guard let wristPoint = recognizedPoints[.wrist] else { return nil }
    
    // Check confidence. If 0.2, the point wasn't reliably detected.
    guard wristPoint.confidence >= 0.2 else { return nil }
    
    // Convert points from Vision coordinates to AVFoundation coordinates.
    let convertedWristPoint = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
    
    return convertedWristPoint
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // wrist may be nil when no reliable point was detected; processPoint handles nils - Copilot assistance
        var wrist: CGPoint?

        defer {
            DispatchQueue.main.sync {
                self.processPoint(point: wrist)
            }
            self.detection = self.beatBuffer.getTempo()
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a body pose was detected in the frame.
            // The Apple template dealing with hands from which I'm working says, "since we set the maximumHandCount property of the request to 1, there will be at most one observation," but I'll leave this in unless it ends up not detecting anything.
       
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            
            // processObservation returns an optional CGPoint; if nil, show an error and leave wrist as nil - Copilot assistance
            if let wristPoint = processObservation(observation) {
                wrist = wristPoint
            } else {
                let error = AppError.poseEstimation(reason: "No wrist point reliably detected")
                DispatchQueue.main.async {
                    error.displayInViewController(self)
                }
                // wrist remains nil and will be handled in processPoint - Copilot assistance
            }
            
            } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}

