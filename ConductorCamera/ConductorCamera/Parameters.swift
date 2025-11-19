//
//  Parameters.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/17/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit

public struct Parameters {
    public let visionObservationConfidence = Float(0.2)
    // buffer capacity will end up being frameRate * maxObservationWindow, but I can't set it from this class because it's initialized BeatBuffer before self is available
    public let handCapacity = 100
    public let frameRate = 30.0 // how do i actually maniuplate the camera frame rate?
    public let maxObservationWindow = 10.0
    public let handFilterWeight = 0.9
    public let displayFilterWeight = 0.9
    public let displayColor = UIColor.black
}
