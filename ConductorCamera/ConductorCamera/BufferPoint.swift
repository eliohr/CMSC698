//
//  BufferPoint.swift
//  HandPose
//
//  Created by Eli Hooker Reese on 10/9/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class BufferPoint {
    
    private var point = CGPoint()
    private var time = Date()
    
    init(point: CGPoint = CGPoint(), time: Date = Date()) {
        self.point = point
        self.time = time
    }
    
}
