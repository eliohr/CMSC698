//
//  MIDIEvent.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/19/25.
//  Copyright © 2025 Apple. All rights reserved.
//

// Wraps MIDIKit's MIDIEvent enum to be displayed in the hand-midi menus

import MIDIKit

enum HandAttribute: String, CaseIterable {
    case mcpX = "x-position"
    case mcpY = "y-position"
    case closedness = "closedness"
    case distanceTP = "thumb-pointer distance"
}

extension MIDIEvent {
    
    // picker representations
    var displayName: String {
        switch self {
        case .pitchBend:
            return "Pitch Bend"
        case .pressure:
            return "Mono Aftertouch/Pressure"
        case let .cc(ccEvent):
            return ccEvent.controller.name
        default:
            return "N/A"
        }
    }
}


// Chat-GPT generated

extension MIDIEvent {
    // A compact, metadata-driven list of pickable events:
    // - Pitch Bend
    // - Channel Pressure (Aftertouch)
    // - All CC controllers exposed by MIDIKit
    //
    // Values and channels are placeholders suitable for picker display.
    // Actual values/channels should be set when sending.
    static let allPickableEvents: [MIDIEvent] = {
        var events: [MIDIEvent] = [
            // Neutral placeholders for display; adjust when sending live data.
            .pitchBend(value: .midi1(0), channel: 0),
            .pressure(amount: .midi1(0), channel: 0)
        ]
        
        // Append all CC controllers provided by MIDIKit
        // (If your MIDIKit version exposes a different API for iterating controllers,
        // we can adapt this.)
        let ccEvents: [MIDIEvent] = MIDIEvent.CC.Controller.allCases.map { controller in
            .cc(controller, value: .midi1(0), channel: 0)
        }
        
        events.append(contentsOf: ccEvents)
        return events
    }()
}

// Wrapper that allows a "None" option alongside concrete MIDIEvent values.
enum PickableMIDIEvent: Equatable {
    case none
    case event(MIDIEvent)
    
    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .event(let e):
            return e.displayName
        }
    }
    
    // Data source for pickers: include "None" first, then all pickable MIDI events.
    static let options: [PickableMIDIEvent] = {
        [.none] + MIDIEvent.allPickableEvents.map { .event($0) }
    }()
}
