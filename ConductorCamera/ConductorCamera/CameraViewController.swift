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
    
    private let drawPath = UIBezierPath()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    
    private var observation = Observation()
    private var lastObservationTimestamp = Date()
    
    private let parameters = Parameters()
    private let midiDevice = MidiDevice()
    private let visionController = VisionController()
    
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
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // may be nil when no reliable point was detected
        var recognizedPoints: [VNRecognizedPoint?]?

        defer {
            
            DispatchQueue.main.async {
                self.midiDevice.broadcastState()
            }
            
            // Gemini assistance with GCD async to keep this from adding latency to the MIDI broadcast thread
            DispatchQueue.global(qos: .userInitiated).async {
                // unwrap the optionals and send coordinates to overlay
                let processedPoints = visionController.processPoints(points: recognizedPoints)
                cameraView.showPoints(color: .clear, points: processedPoints)
            }
            
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand pose was detected in the frame.
            guard let poseRequestResult = handPoseRequest.results?.first else {
                return
            }
            
            // processObservation returns an object of struct hand
            guard let hand = visionController.processObservation(poseRequestResult) else {
                print("failed to process observation")
                return
            }
            
            // update timestamp upon successful observation processing
            lastObservationTimestamp = Date()
            
            // send the new hand info to the midi device
            midiDevice.updateState(hand: hand)
            
            } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}

