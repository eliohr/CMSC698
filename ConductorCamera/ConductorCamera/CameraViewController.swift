/*
See the APPLE-LICENSE.txt file for this sample’s licensing information.

Abstract: The app's main view controller object.
*/

import UIKit
import AVFoundation
import Vision
import MIDIKit

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
    
    var handAttribute: HandAttribute = .mcpX
    var midiEvent: MIDIEvent = .pitchBend(value: MIDIEvent.ChanVoice14Bit32BitValue.unitInterval(0.5), channel: 0)
    
    // settings view toggle - modified from gemini generation
    @IBOutlet weak var settingsViewToggle: UIView!
    @IBAction func settings(_ sender: UIButton) {
        settingsViewToggle.isHidden.toggle()
    }
    @IBOutlet weak var settings: UIButton!
    
    // midi peripheral setup and test from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    @IBAction func setup(_ sender: Any) {
        let sheetViewController = BTMIDIPeripheralViewController(nibName: nil, bundle: nil)
        present(sheetViewController, animated: true, completion: nil)
    }
    // Chat-GPT modified midi manager and test with console output here
    @IBAction func test(_ sender: Any) {
        let appDelegate = midiDevice.appDelegate
        
        guard let manager = appDelegate?.midiManager else {
            print("[MIDI Test] midiManager not available")
            return
        }
        
        let managedKeys = Array(manager.managedOutputConnections.keys)
        print("[MIDI Test] Managed output connection keys: \(managedKeys)")
        
        let inputs = manager.endpoints.inputs
        let outputs = manager.endpoints.outputs
        print("[MIDI Test] Inputs discovered: \(inputs.count)")
        inputs.forEach { print("  [Input] \($0.name) (id: \($0.id))") }
        print("[MIDI Test] Outputs discovered: \(outputs.count)")
        outputs.forEach { print("  [Output] \($0.name) (id: \($0.id))") }
        
        guard let conn = manager.managedOutputConnections["Broadcaster"] else {
            print("[MIDI Test] Broadcaster connection not found.")
            return
        }
        
        do {
            try conn.send(event: .pitchBend(value: .unitInterval(0.5), channel: 0))
            print("[MIDI Test] pitch bend event sent")
        } catch {
            print("[MIDI Test] failed to send pitch bend event: \(error)")
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
    
    @IBAction func updateAttributes(_ sender: Any) {
        midiDevice.updateAttributes(from: handAttribute, to: midiEvent)
    }
    
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
        
        // Chat-GPT fix
        // Set default title for fromPick
        fromPick.setTitle(handAttribute.rawValue, for: .normal)
        // Configure the menu for the "From" button to pick a HandAttribute
        fromPick.showsMenuAsPrimaryAction = true
        if #available(iOS 15.0, *) {
            fromPick.changesSelectionAsPrimaryAction = true
        }
        // Build actions from HandAttribute cases and forward selection to fromMenu(_:)
        let actions: [UIAction] = HandAttribute.allCases.map { attribute in
            let isDefault = (attribute == handAttribute)
            return UIAction(
                title: attribute.rawValue,
                image: nil,
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: [],
                state: isDefault ? .on : .off
            ) { [weak self] action in
                self?.fromMenu(action)
            }
        }
        fromPick.menu = UIMenu(title: "Select Attribute", children: actions)
        
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
            
            // Gemini assistance with GCD async to keep this from adding latency to the MIDI broadcast thread
            DispatchQueue.global(qos: .userInitiated).async {
                
                // i really want clearing points to work but it's like weird and unreliable
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
            midiDevice.updateAndBroadcastState(hand: h)
            
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
