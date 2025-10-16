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
    private var velocity = 0.0
    private var acceleration = 0.0
    private var isBeat = false
    private var isDownbeat = false
    
    init(point: CGPoint = CGPoint(), time: Date = Date()) {
        self.rawPoint = point
        self.time = time
    }
    
    
    
}
