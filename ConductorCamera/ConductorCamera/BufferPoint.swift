//
//  BufferPoint.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/15/25.
//  Copyright © 2025 Apple. All rights reserved.
//
//  I learned about the EMA filter using Gemini and YouTube (https://www.youtube.com/watch?v=iPYacJZM5Z0)
//  Gemini suggested the velocity and acceleration variables all be stored in this object

import UIKit
import AVFoundation

class BufferPoint {
    
    private var rawPoint = CGPoint()
    private var time = Date()
    private var velocity = CGVector()
    private var acceleration = CGVector()
    private var isBeat = false
    private var isDownbeat = false
    
    init(point: CGPoint = CGPoint(), time: Date = Date()) {
        self.rawPoint = point
        self.time = time
    }
    
    // MARK: - Mutator Methods (The "Setters" for the PeakBuffer)
    // Gemini suggested this in response to my instinct to use the conventional Java approach of public getters and setters
        
        /**
         Updates the calculated kinematic values.
         This method is called by the PeakBuffer after comparing this point to the previous one.
         */
        func updateCalculatedValues(velocity: CGVector, acceleration: CGVector) {
            self.velocity = velocity
            self.acceleration = acceleration
        }
        
        /**
         Sets the beat detection flags.
         This method is called by the PeakDetectionAlgorithm.
         */
        func setBeatFlags(isBeat: Bool, isDownbeat: Bool) {
            self.isBeat = isBeat
            self.isDownbeat = isDownbeat
        }
    
}
