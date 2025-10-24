//
//  Parameters.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/17/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import AVFoundation

public struct Parameters {
    public let visionObservationConfidence = Float(0.2)
    public let frameRate = 60.0
    public let resolution = 360
    // buffer capacity will end up being frameRate * maxObservationWindow, but I can't set it from this class because CameraViewController initializes its instance of BeatBuffer "before self is available"
    public let bufferCapacity = 300
    
    public let timeFilterWeight = 0.5
    public let pointFilterWeight = 0.9
    public let accelerationFilterWeight = 0.7
    
    public let accelerationThreshold = 1.0
    public let timeIntervalThreshold = 0.1
    
    public let beatsCapacity = 10
    public let tempoRange = (60,240)
    public let tempoHysterisis = 0 // will consider this later
}
