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
    public let frameRate = 30.0 // how do i actually maniuplate the camera frame rate?
    public let resolution = CGSize(width: 1920, height: 1080)
    public let maxObservationWindow = 10.0
    public let handFilterWeight = 0.7
    public let displayFilterWeight = 0.7
    public let displayColor = UIColor.black
}
