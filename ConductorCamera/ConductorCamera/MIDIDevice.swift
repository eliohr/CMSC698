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
    
    let parameters = Parameters()
    
    // the current hand information we'll convert to send through midi events
    private var currentHand = Hand()
    
    // the previous hand information we'll use to filter the current hand and check if we need to send a new event
    private var previousHand = Hand()
    
    // this dictionary stores the current associations between hand attributes and midi events as they're defined in the MIDIEvent class
    private var attributeMIDIEvents: [HandAttribute: MIDIEvent] = [:]
    
    // peripheral setup from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    public func broadcastState() {
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        
        for (a, e) in attributeMIDIEvents {
            
            let currentValue = currentHand.getValue(for: a)
            let previousValue = previousHand.getValue(for: a)
            
            // send a new event if the value of the hand attribute changed — this isn't working cause we're comparing filtered values
            if (currentValue != previousValue) {
                let handedEvent: MIDIEvent
                
                switch e {
                case .pitchBend(_): handedEvent = .pitchBend(value: .unitInterval(currentValue), channel: 0)
                case .pressure(_): handedEvent = .pressure(amount: .unitInterval(currentValue), channel: 0)
                case .cc(let cc): handedEvent = .cc(cc.controller,value: .unitInterval(currentValue), channel: 0)
                default: continue
                }
                
                do {
                    try conn?.send(event: handedEvent)
                } catch {
                    AppError.midiBroadcast(reason: error.localizedDescription).displayInViewController(self)
                }
            }
            
        }
    }
    
    // update current hand info
    public func updateState(hand: Hand) {
        let temporaryHand = currentHand
        currentHand = currentHand.filterHand(currentValue: hand, previousValue: previousHand, weight: parameters.handFilterWeight)
        previousHand = temporaryHand
    }
    
    // set the new hand-MIDI association
    public func updateAttributes(from: HandAttribute, to: MIDIEvent) {
        attributeMIDIEvents[from] = to
    }
    
    /// TODO:
    /// "nothing" option for a hand parameter to not record any data
    /// calibration mode to associate the range of x, y, c, and t values the user will send to the Unit Interval range
}
