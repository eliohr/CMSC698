//
//  MidiDevice.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/22/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import UIKit
import MIDIKit

class MyMIDIDevice: UIViewController {
    
    let parameters = Parameters()
    
    private var learning = false
    
    // the raw hand information we receive within updateState
    private var rawHand = Hand()
    
    // the filtered hand information we convert to send through midi events
    private var filteredHand = Hand()
        
    // the previous raw hand information we use to check if we need to do anything
    private var previousHand = Hand()
    
    // this dictionary stores the current associations between hand attributes and midi events as they're defined in the MIDIEvent class
    private var attributeMIDIEvents: [HandAttribute: MIDIEvent] = [:]
    
    private var learningStoring: [HandAttribute: MIDIEvent] = [:]
    
    // peripheral setup from https://github.com/orchetect/MIDIKit/tree/main/Examples/SwiftUI%20iOS/BluetoothMIDI
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    public func updateAndBroadcastState(hand: Hand) {
        
        print(attributeMIDIEvents)
        
        // update current hand info
        let previousFilteredHand = filteredHand
        previousHand = rawHand
        rawHand = hand
        filteredHand = rawHand.filterHand(previousValue: previousFilteredHand, weight: parameters.handFilterWeight)
                
        for (attribute, event) in attributeMIDIEvents { sendMIDIEvent(a: attribute, e: event) }
                
    }
    
    // temporarily only use the mapping we're learning
    public func learnMode(from: HandAttribute, to: MIDIEvent) {
        learningStoring = attributeMIDIEvents
        clearMIDIAttributes()
        attributeMIDIEvents = [from:to]
    }
    
    // this is its own function so I can access it from the camera view controller
    public func clearMIDIAttributes() {
        attributeMIDIEvents.removeAll()
    }
    
    // revert to using all the mappings and set the new hand-MIDI association
    public func updateAttributes(from: HandAttribute, to: MIDIEvent) {
        attributeMIDIEvents = learningStoring
        attributeMIDIEvents[from] = to
    }
    
    private func sendMIDIEvent(a: HandAttribute, e: MIDIEvent) {
        
        let conn = appDelegate?.midiManager.managedOutputConnections["Broadcaster"]
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
                default: return
            }
            
            do {
                try conn?.send(event: handedEvent)
            } catch {
                AppError.midiBroadcast(reason: error.localizedDescription).displayInViewController(self)
            }
        }
    }
    
}
