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
    private let midiDevice = MidiDevice()
    
    private var visionController = VisionController()
    
    // peripheral setup from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBAction func showBluetoothMIDILocalSetup(_ sender: Any) {
        let sheetViewController = BTMIDIPeripheralViewController(nibName: nil, bundle: nil)
        present(sheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func sendTestMIDIEvent(_ sender: Any) {
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        try? conn?.send(event: .noteOn(60, velocity: .midi1(64), channel: 0))
        print("sending test signal")
        
        // wait a second before turning off the note Gemini async syntax ssistance
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            try? conn?.send(event: .noteOff(60, velocity: .midi1(64), channel: 0))
        }
        
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
    
    func processPoints(point: CGPoint?) {
        // Check that we have both points.
        guard let newPoint = point else { return }
        
        // add new points to beat buffer
        let newVisionCalculation = VisionCalculation(point: newPoint)
        newProcessedPoint = beatBuffer.addPoint(currentPoint: newBufferPoint)
        
    }
    
    // modified from https://developer.apple.com/documentation/vision/detecting-human-body-poses-in-images with suggestions from Google Gemini
    func processObservationn(_ observation: VNHumanHandPoseObservation) -> CGPoint? {
        
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
        var recognizedPoints: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]?

        defer {
            
            DispatchQueue.main.async {
                let processedPoints = visionController.processPoints(points: recognizedPoints)
                // MARK: START HERE ONCE YOU'RE READY TO SEND MIDI TEMPO INFO
                cameraView.showPoints(color: .clear, points: processedPoints)
            }
            
            // GCD async thread-switching syntax from Gemini
            DispatchQueue.global(qos: .userInitiated).async {
                let newTempo = self.beatBuffer.getTempo()
                
                // Gemini recommended swtiching to the main thread to broadcast midi information
                DispatchQueue.main.async {
                    self.midiDevice.broadcastMidiTempo(tempo: newTempo)
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
            if let observation = processObservation(observation) {
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

