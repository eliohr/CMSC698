/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract: The app's delegate object.
MIDI manager modified from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
*/

import UIKit
import Vision

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
<<<<<<< Updated upstream
=======
    
    // MARK: - instantiate midi manager
    let midiManager = MIDIManager(
        clientName: "midiManager",
        model: "GestureControl",
        manufacturer: "Eli Orion"
    )
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        // start midi manager
        do {
            try midiManager.start()
        } catch {
            print("Error while starting MIDI manager: ", error.localizedDescription)
        }
        
        // set up a broadcaster that can send events to all MIDI inputs
        do {
            try midiManager.addOutputConnection(
                to: .allInputs, // auto-connect to all inputs that may appear
                tag: "Broadcaster",
                filter: .owned() // don't allow self-created virtual endpoints
            )
        } catch {
            print(
                "Error setting up managed MIDI all-listener connection:",
                error.localizedDescription
            )
        }
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

// MARK: - Errors

enum AppError: Error {
    case captureSessionSetup(reason: String)
    case visionError(error: Error)
    case otherError(error: Error)
    case poseEstimation(reason: String)
    
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
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

