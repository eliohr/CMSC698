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
    private var lastObservationTimestamp = Date()
    private let parameters = Parameters()
    private var beatBuffer = BeatBuffer(capacity: 300)
    // private let midiDevice = MidiDevice()
    
    private var newProcessedPoint = BufferPoint()
    private var newTempo = Tempo(bpm: 120.0, meter: 4, beat: 1)
    
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
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        
        session.addInput(deviceInput)
        
        let r = parameters.resolution
        let f = parameters.frameRate
        
        // Gemini generated configuration
        guard let desiredFormat = videoDevice.formats.first(where: { format in
            // check resolution
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            guard dimensions.height == r else {
                return false
            }
            // check framerate
            return format.videoSupportedFrameRateRanges.contains { range in
                return range.minFrameRate <= f && range.maxFrameRate >= f
            }
        }) else {
            throw AppError.captureSessionSetup(reason: "Device does not support desired format.")
        }
        
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeFormat = desiredFormat
            let frameDuration = CMTime(value: 1, timescale: Int32(f))
            videoDevice.activeVideoMinFrameDuration = frameDuration
            videoDevice.activeVideoMaxFrameDuration = frameDuration
            videoDevice.unlockForConfiguration()
            print("Capture device configured at resolution of \(parameters.resolution) and frame rate of \(parameters.frameRate)")
        } catch {
            throw AppError.captureSessionSetup(reason: "Could not configure video device input.")
        }
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
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
        guard let newPoint = point else { return }
        
        // add new points to beat buffer
        let newBufferPoint = BufferPoint(point: newPoint, time: lastObservationTimestamp)
        newProcessedPoint = beatBuffer.addPoint(currentPoint: newBufferPoint)
        
        // MARK: START HERE ONCE YOU'RE READY TO SEND MIDI TEMPO INFO
        cameraView.showPoints(color: .clear, point: newProcessedPoint)
        cameraView.showTempo(color: .clear, tempo: newTempo)
        
    }
    
    // modified from https://developer.apple.com/documentation/vision/detecting-human-body-poses-in-images with suggestions from Google Gemini
    func processObservation(_ observation: VNHumanHandPoseObservation) -> CGPoint? {
        
        // Retrieve all recognized points from the observation.
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else { return nil }
        
        // Get the specific wrist point.
        guard let wristPoint = recognizedPoints[.wrist] else { return nil }
        
        // Check confidence. If 0.2, the point wasn't reliably detected.
        guard wristPoint.confidence >= parameters.visionObservationConfidence else { return nil }
        
        // Convert points from Vision coordinates to AVFoundation coordinates.
        let convertedWristPoint = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
        
        return convertedWristPoint
        
    }
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // wrist may be nil when no reliable point was detected; processPoint handles nils - Copilot assistance
        var wrist: CGPoint?

        defer {
            
            DispatchQueue.main.async {
                self.processPoint(point: wrist)
            }
            
            // GCD async thread-switching syntax from Gemini
            DispatchQueue.global(qos: .userInitiated).async {
                let newTempo = self.beatBuffer.getTempo()
                
                // Gemini recommended swtiching to the main thread to broadcast midi information
                DispatchQueue.main.async {
                    // self.midiDevice.broadcastMidiTempo(tempo: newTempo)
                }
            }
            
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a body pose was detected in the frame.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            
            // processObservation returns an optional CGPoint; if nil, show an error and leave wrist as nil - Copilot assistance
            if let wristPoint = processObservation(observation) {
                wrist = wristPoint
                // update timestamp upon successful detection of a wrist point
                lastObservationTimestamp = Date()
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

