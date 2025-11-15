//
//  MidiDevice.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/22/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit

class MidiDevice: UIViewController {
    
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
        
        // wait a second before turning off the note - Gemini async syntax ssistance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            try? conn?.send(event: .noteOff(60, velocity: .midi1(64), channel: 0))
        }
        
    }
    
    public func broadcastState() {
        // ONLY IF THERE'S ANY CHANGE IN ANY OF THE PARAMETERS SEND THE NEW VALUE TO THE CHANNEL ASSOCIATED WITH IT
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        try? conn?.send(event: .cc(.expression, value: .midi1(64), channel: 0))
    }
    
    public func updateState(hand: Hand) {
        
    }
    
}
