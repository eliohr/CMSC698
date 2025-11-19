/*
See the APPLE-LICENSE.txt file for this sample’s licensing information.

Abstract: The app's main view controller object.
*/

import UIKit
import AVFoundation
import Vision

enum HandAttribute: String, CaseIterable {
    case xPosition = "x-position"
    case yPosition = "y-position"
    case closedness = "closedness"
    case thumbPointerDistance = "thumb-pointer distance"
}

class CameraViewController: UIViewController {
    
    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    // private var observation = Observation()
    private var lastObservationTimestamp = Date()
    
    private let parameters = Parameters()
    private let midiDevice = MidiDevice()
    private let visionDevice = VisionDevice()
    
    // The single, pre-populated data source for the picker
    let midiEventOptions: [MIDIEvent] = MIDIEvent.allPickableEvents
    
    var handAttribute: HandAttribute = .xPosition
    var midiEvent: MIDIEvent = .PitchBend(value: 0)
    
    // settings view toggle - modified from gemini generation
    @IBOutlet weak var settingsViewToggle: UIView!
    @IBAction func settings(_ sender: UIButton) {
        settingsViewToggle.isHidden.toggle()
    }
    @IBOutlet weak var settings: UIButton!
    
    // midi peripheral setup and test
    @IBAction func setup(_ sender: Any) {
        let sheetViewController = BTMIDIPeripheralViewController(nibName: nil, bundle: nil)
        present(sheetViewController, animated: true, completion: nil)
    }
    @IBAction func test(_ sender: Any) {
        let appDelegate = midiDevice.appDelegate
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        try? conn?.send(event: .noteOn(60, velocity: .midi1(64), channel: 0))
        print("sending test signal")
        
        // wait a second before turning off the note - Gemini async syntax ssistance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            try? conn?.send(event: .noteOff(60, velocity: .midi1(64), channel: 0))
        }
    }
    @IBOutlet weak var fromPick: UIButton!
    
    // Gemini assistance
    @IBAction func fromMenu(_ sender: UIAction) {
        let title = sender.title
        if let selectedAttribute = HandAttribute(rawValue: title) {
            handAttribute = selectedAttribute
            fromPick.setTitle(selectedAttribute.rawValue, for: .normal)
        } else {
            print("Error: Menu item title '\(title)' does not match any HandAttribute.")
        }
    }
    @IBOutlet weak var toPick: UIPickerView!
    
    private let drawOverlay = CAShapeLayer()
    private let drawPath = UIBezierPath()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    override func viewDidLoad() {
        
        settingsViewToggle.isHidden = true // start with settings hidden
        
        super.viewDidLoad()
        
        drawOverlay.frame = view.layer.bounds
        drawOverlay.backgroundColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.5).cgColor
        settingsViewToggle.layer.zPosition = 9
        settings.layer.zPosition = 9
        view.layer.addSublayer(drawOverlay)
        
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        
        fromPick.setTitle(handAttribute.rawValue, for: .normal)
        
        toPick.dataSource = self
        toPick.delegate = self
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
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // may be nil when no reliable points are detected
        var recognizedPointsOp: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]?
        var handOp: Hand?

        defer {
            
            DispatchQueue.main.async {
                self.midiDevice.broadcastState()
            }
            
            // Gemini assistance with GCD async to keep this from adding latency to the MIDI broadcast thread
            DispatchQueue.global(qos: .userInitiated).async {
                
                // i really want clearing points to work but it doesn't
                /*
                if Date().timeIntervalSince(self.lastObservationTimestamp) > 2.0 {
                    self.cameraView.clearPoints()
                }
                */
                
                let viewSize = self.cameraView.previewLayer.bounds.size

                guard let recognizedPoints = recognizedPointsOp else {
                    return
                }

                let processedPoints = self.visionDevice.processPoints(points: recognizedPoints, viewSize: viewSize)
                self.cameraView.showPoints(processedPoints, color: .black)
            }
            
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand pose was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else { return }
            
            // returns [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]? - cursor syntax assistance
            recognizedPointsOp = visionDevice.recognizePoints(observation)
            guard let recognizedPoints = recognizedPointsOp else { return }
            
            // update timestamp upon successful observation processing
            lastObservationTimestamp = Date()
            
            // send new hand info to midi device
            handOp = visionDevice.toHand(points: recognizedPoints)
            guard let h = handOp else { return }
            midiDevice.updateState(hand: h, from: handAttribute, to: midiEvent)
            
            } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}

// Gemini generated
extension CameraViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return midiEventOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        midiEvent = midiEventOptions[row]
        }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let event = midiEventOptions[row]
        return event.displayName
    }
}
