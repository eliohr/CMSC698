//
//  VisionController.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/13/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Vision
import UIKit

class VisionDevice {
    
    private let parameters = Parameters()
    
    // grab all recognized points at the specified confidence level from the observation - modified from cursor generation
    func recognizePoints(_ result: VNHumanHandPoseObservation) -> [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]? {
        
        guard let recognizedPoints = try? result.recognizedPoints(.all) else {
            print("failed to get recognized points")
            return nil
        }
        
        let filteredPoints = recognizedPoints.filter { $0.value.confidence >= parameters.visionObservationConfidence }
        
        return filteredPoints.isEmpty ? nil : filteredPoints
    }
    
    // convert from Vision to AVFoundation coordinate and scale - modified from cursor generation
    func processPoints(points: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint], viewSize: CGSize) -> [CGPoint] {
        
        var pointsCG: [CGPoint] = []
        
        for (_, recognizedPoint) in points {
            // Convert from Vision coordinate system (bottom-left origin) to AVFoundation (top-left origin)
            let normalizedPoint = CGPoint(
                x: recognizedPoint.location.x,
                y: 1 - recognizedPoint.location.y
            )
            
            // Scale to actual view size and rotate
            let scaledPoint = CGPoint(
                x: normalizedPoint.y * viewSize.width,
                y: normalizedPoint.x * viewSize.height
            )
            
            pointsCG.append(scaledPoint)
        }
        
        return pointsCG
    }
    
    
    // convert recognized points to hand - modified from cursor generation
    func toHand(points: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> Hand? {
        
        // return nil if indexMCP is not found
        guard let indexMCPPoint = points[.indexMCP] else {
            return nil
        }
        
        var distances: [CGFloat] = []
        for (_, point) in points {
            let dx = point.location.x - indexMCPPoint.location.x
            let dy = point.location.y - indexMCPPoint.location.y
            let distance = hypot(dx, dy)
            distances.append(distance)
        }
        
        // the average distance from other points in the hand to the index finger’s metacarpophalangeal joint
        let closedness = distances.isEmpty ? 0.0 : Double(distances.reduce(0, +) / CGFloat(distances.count))
        
        let dx = (points[.thumbTip]?.location.x ?? 0.0) - (points[.indexTip]?.location.x ?? 0.0)
        let dy = (points[.thumbTip]?.location.x ?? 0.0) - (points[.indexTip]?.location.x ?? 0.0)
        
        // the distance from the thumb tip to the index tip
        let distanceTP = hypot(dx, dy)
        
        return Hand(x: Double(1-indexMCPPoint.location.y), y: Double(1-indexMCPPoint.location.x), d: distanceTP, c: closedness)
    }
    
}
