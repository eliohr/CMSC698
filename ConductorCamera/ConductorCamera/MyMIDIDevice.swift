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
    
    // the raw hand information we receive within updateState
    private var rawHand = Hand()
    
    // the filtered hand information we convert to send through midi events
    private var filteredHand = Hand()
        
    // the previous raw hand information we use to check if we need to do anything
    private var previousHand = Hand()
    
    // this dictionary stores the current associations between hand attributes and midi events as they're defined in the MIDIEvent class
    private var attributeMIDIEvents: [HandAttribute: MIDIEvent] = [:]
    
    // peripheral setup from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    public func updateAndBroadcastState(hand: Hand) {
        
        print("x: \(Int(filteredHand.mcpX*100))" +
              "\n y: \(Int(filteredHand.mcpY*100))" +
              "\n index: \(Int(filteredHand.distanceTP*100))" +
              "\n middle: \(Int(filteredHand.distanceTM*100))" +
              "\n pinky: \(Int(filteredHand.distanceTL*100))")
        
        // update current hand info
        let previousFilteredHand = filteredHand
        previousHand = rawHand
        rawHand = hand
        filteredHand = rawHand.filterHand(previousValue: previousFilteredHand, weight: parameters.handFilterWeight)
        
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
        
        for (a, e) in attributeMIDIEvents {
            
            let currentValue = rawHand.getValue(for: a)
            let previousValue = previousHand.getValue(for: a)
            
            // send a new event if the value of the hand attribute changed — this isn't working cause we're comparing filtered values
            if (currentValue != previousValue) {
                let currentFilteredValue = filteredHand.getValue(for: a)
                
                let handedEvent: MIDIEvent
                
                switch e {
                    // *2 cause i guess that's how pitch bend values work
                    case .pitchBend(_): handedEvent = .pitchBend(value: .unitInterval(currentFilteredValue*2), channel: 0)
                    case .pressure(_): handedEvent = .pressure(amount: .unitInterval(currentFilteredValue), channel: 0)
                    case .cc(let cc): handedEvent = .cc(cc.controller,value: .unitInterval(currentFilteredValue), channel: 0)
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
    
    // set the new hand-MIDI association
    public func updateAttributes(from: HandAttribute, to: MIDIEvent) {
        attributeMIDIEvents[from] = to
    }
    
}
