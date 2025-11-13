//
//  VisionCalculation.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/13/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Vision

class VisionController {
    
    private let parameters = Parameters()
    
    func processPoints(points: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]?) {
        
        // check that we have some observed points
        guard let points = points else { return }
        
        // perform vision calculation on new points
        let newVisionCalculation = visionCalculation(points: points)
        
    }
    
    func visionCalculation(points: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        // modified from https://developer.apple.com/documentation/vision/detecting-human-body-poses-in-images with suggestions from Google Gemini
        func processObservationn(_ observation: VNHumanHandPoseObservation) -> CGPoint? {
            
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
    
}
