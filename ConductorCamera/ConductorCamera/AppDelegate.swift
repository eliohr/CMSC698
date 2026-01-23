/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract: The app's delegate object.
MIDI manager modified from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
*/

import UIKit
import Vision
import MIDIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    // MARK: - instantiate and start midi manager
    // https://orchetect.github.io/MIDIKit/documentation/midikitio/midimanager/
    let midiManager = MIDIManager(
        clientName: "midiManager",
        model: "GestureControl",
        manufacturer: "Eli Orion"
    )
    
    // Chat-GPT fix for inconcsistent peripheral connection: "initialize MIDI as early and reliably as possible"
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let path = Bundle.main.path(forResource: "appicon", ofType: "png") {
            let startupImage = UIImage(contentsOfFile: path)
        }
        
        // it was annoying for it to keep turning off while playing—i assume people are used to the idea of an app that always displays the camera feed never shutting off on its own
        UIApplication.shared.isIdleTimerDisabled = true
        
        print("[MIDI] didFinishLaunching: starting MIDI manager...")
        do {
            try midiManager.start()
            print("[MIDI] Manager started.")
        } catch {
            print("[MIDI] Error while starting MIDI manager: \(error.localizedDescription)")
        }
        
        // set up a broadcaster that can send events to all MIDI inputs
        do {
            try midiManager.addOutputConnection(
                to: .allInputs, // auto-connect to all inputs that may appear
                tag: "Broadcaster",
                filter: .owned() // don't allow self-created virtual endpoints
            )
            print("[MIDI] Managed output connection 'Broadcaster' added.")
        } catch {
            print("[MIDI] Error setting up managed MIDI 'Broadcaster' connection: \(error.localizedDescription)")
        }
        
        // Optional: print endpoints at launch to verify CoreMIDI sees anything
        logMIDIEndpoints(context: "[MIDI] Post-init")
        
        return true
    }
    
    // Chat-GPT: "keep this minimal; no MIDI setup here anymore"
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - Debug helpers
    
    private func logMIDIEndpoints(context: String) {
        // MIDIKit exposes endpoints via its manager properties; adjust if your version differs.
        let inputs = midiManager.endpoints.inputs
        let outputs = midiManager.endpoints.outputs
        
        print("\(context) - Inputs discovered: \(inputs.count)")
        for ep in inputs {
            print("  [Input] \(ep.name) (id: \(ep.id))")
        }
        
        print("\(context) - Outputs discovered: \(outputs.count)")
        for ep in outputs {
            print("  [Output] \(ep.name) (id: \(ep.id))")
        }
        
        let managedKeys = midiManager.managedOutputConnections.keys
        print("\(context) - Managed output connection keys: \(Array(managedKeys))")
    }
}


// MARK: - Errors

enum AppError: Error {
    case captureSessionSetup(reason: String)
    case visionError(error: Error)
    case otherError(error: Error)
    case poseEstimation(reason: String)
    case midiBroadcast(reason: String)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            AppError.otherError(error: error).displayInViewController(viewController)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .visionError(let error):
            title = "Vision Error"
            message = error.localizedDescription
        case .otherError(let error):
            title = "Error"
            message = error.localizedDescription
        case .poseEstimation(let reason):
            title = "Pose Estimation Error"
            message = reason
        case .midiBroadcast(let reason):
            title = "MIDI Broadcast Error"
            message = reason
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
