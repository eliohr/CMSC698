//
//  Parameters.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/17/25.
//  Copyright © 2025 Apple. All rights reserved.
//

public struct Parameters {
    public let visionObservationConfidence = Float(0.2)
    // buffer capacity will end up being frameRate * maxObservationWindow, but I can't set it from this class because it's initialized BeatBuffer before self is available
    public let frameRate = 30.0 // how do i actually maniuplate the camera frame rate?
    public let maxObservationWindow = 10.0
    public let pointFilterWeight = 0.8
    public let accelerationFilterWeight = 0.5
    public let beatThreshold = 0
    public let tempoRange = (60,240)
    public let tempoHysterisis = 0
}
