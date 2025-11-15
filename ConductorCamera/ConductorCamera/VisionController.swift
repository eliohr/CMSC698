//
//  VisionCalculation.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/13/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Vision
import UIKit

struct Hand {
    var wristX = Double()
    var wristY = Double()
    var distanceTP = Double()
    var closedness = Double()
    
    init(x: Double = Double(), y: Double = Double(), d: Double = Double(), c: Double = Double()) {
        let wristX = x
        let wristY = y
        let distanceTP = d
        let closedness = c
    }
}

class VisionController {
    
    private let parameters = Parameters()
    
    func processPoints(points: [VNRecognizedPoint?]?) {
        
        // check that we have some observed points
        guard let points = points else { return }
        
        // add new points to beat buffer
        let newVisionCalculation = VisionCalculation(point: newPoint)
        newProcessedPoint = beatBuffer.addPoint(currentPoint: newBufferPoint)
        
    }
    
    // modified from https://developer.apple.com/documentation/vision/detecting-human-body-poses-in-images with suggestions from Google Gemini
    func processObservation(_ observation: VNHumanHandPoseObservation) -> Hand? {
        
        // Retrieve all recognized points from the observation.
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else { return nil }
        
        // Get the specific wrist point.
        guard let wristPoint = recognizedPoints[.wrist] else { return nil }
        
        // Check confidence. If 0.2, the point wasn't reliably detected.
        guard wristPoint.confidence >= parameters.visionObservationConfidence else { return nil }
        
        // Convert points from Vision coordinates to AVFoundation coordinates.
        let convertedWristPoint = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
        
        return convertedWristPoint

    }
    
}
