//
//  MidiDevice.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/22/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import MIDIKit

class MidiDevice: UIViewController {
    
    var attributeMIDIEvents: [HandAttribute: MIDIEvent] = [
        .xPosition: .ControlChange(.Pan),
        .yPosition: .PitchBend(value: 8192),
        .closedness: .ControlChange(.ChannelVolume),
        .thumbPointerDistance: .ControlChange(.SustainPedal),
    ]
    
    // peripheral setup from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    public func broadcastState() {
        // ONLY IF THERE'S ANY CHANGE IN ANY OF THE PARAMETERS SEND THE NEW VALUE TO THE CHANNEL ASSOCIATED WITH IT
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        try? conn?.send(event: .cc(.expression, value: .midi1(64), channel: 0))
    }
    
    public func updateState(hand: Hand, from: HandAttribute, to: MIDIEvent) {
        
        attributeMIDIEvents[from] = to
        
        // cursor quick integerization assistance
        print("x: \(Int(hand.mcpX * 100)), y: \(Int(hand.mcpY * 100)), c: \(Int(hand.closedness * 100)), d: \(Int(hand.distanceTP * 100))")
        
    }
    
    // todo: eventually implement a calibration mode to associate the range of x, y, c, and t values the user will send to the 0-127 midi range
    
}
