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
    
    // the current hand information we'll convert to send through midi events
    private var currentHand = Hand()
    
    // this dictionary stores the current associations between hand attributes and midi events as they're defined in the MIDIEvent class
    private var attributeMIDIEvents: [HandAttribute: MyMIDIEvent] = [
        .mcpX: .ControlChange(.Pan),
        .mcpY: .PitchBend(value: 8192),
        .closedness: .ControlChange(.ChannelVolume),
        .distanceTP: .ControlChange(.SustainPedal),
    ]
    
    // old version that took change into account
    /*
    private var attributeMIDIEvents: [HandAttribute: (MIDIEvent, Bool)] = [
         .mcpX: (.ControlChange(.Pan),false),
         .mcpY: (.PitchBend(value: 8192),false),
         .closedness: (.ControlChange(.ChannelVolume),false),
         .distanceTP: (.ControlChange(.SustainPedal),false),
     ]
     */
    
    // peripheral setup from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    public func broadcastState() {
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        
        let x = attributeMIDIEvents[.mcpX]
        let y = attributeMIDIEvents[.mcpY]
        let c = attributeMIDIEvents[.closedness]
        let d = attributeMIDIEvents[.distanceTP]
        
        try? conn?.send(event: .cc(.expression, value: .midi1(64), channel: 0))
    }
    
    // update current hand info
    public func updateState(hand: Hand) {
        
        currentHand = hand
        
        /*
        // i'll probably implement the decision to broadcast based on whether it changed once we've normalized to the ranges of the midi events
        if (hand.mcpX == currentHand.mcpX) {
            attributeMIDIEvents[.mcpX]?.1 = false
        } else {
            attributeMIDIEvents[.mcpX]?.1 = true
            currentHand.mcpX = hand.mcpX
        }
        
        if (hand.mcpY == currentHand.mcpY) {
            attributeMIDIEvents[.mcpY]?.1 = false
        } else {
            attributeMIDIEvents[.mcpY]?.1 = true
            currentHand.mcpY = hand.mcpY
        }

        if (hand.closedness == currentHand.closedness) {
            attributeMIDIEvents[.closedness]?.1 = false
        } else {
            attributeMIDIEvents[.closedness]?.1 = true
            currentHand.closedness = hand.closedness
        }

        if (hand.distanceTP == currentHand.distanceTP) {
            attributeMIDIEvents[.distanceTP]?.1 = false
        } else {
            attributeMIDIEvents[.distanceTP]?.1 = true
            currentHand.distanceTP = hand.distanceTP
        }
         */
        
    }
    
    // set the new hand-MIDI association
    public func updateAttributes(from: HandAttribute, to: MyMIDIEvent) {
        attributeMIDIEvents[from] = to
    }
    
    // todo: eventually implement a calibration mode to associate the range of x, y, c, and t values the user will send to the 0-127 midi range
    
}
