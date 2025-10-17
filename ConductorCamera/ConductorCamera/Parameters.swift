//
//  Parameters.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/17/25.
//  Copyright © 2025 Apple. All rights reserved.
//

public struct Parameters {
    public let visionObservationConfidence = Float(0.2)
    public let bufferCapacity = 300
    public let pointFilterWeight = 0.5
    public let accelerationFilterWeight = 0.9
    public let beatThreshold = 0
    public let tempoRange = (60,240)
    public let tempoHysterisis = 0
}
