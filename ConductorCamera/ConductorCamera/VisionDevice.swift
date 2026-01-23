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
    
    // convert from Vision to AVFoundation coordinates, remove unnecessary-to-display points, and scale - modified from cursor generation
    func processPoints(points: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint], viewSize: CGSize) -> [CGPoint] {
        
        var pointsCG: [CGPoint] = []
        
        for (name, recognizedPoint) in points {
            
            // only keep the fingertips; i think this could reduce latency? i'm not paying much attention to what else might be affecting performance
            
            if (name == .thumbTip || name == .indexTip || name == .middleTip || name == .littleTip){
                
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
            
        }
        
        return pointsCG
    }
    
    
    // convert recognized points to hand - modified from cursor generation
    func toHand(points: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> Hand? {
        
        // return nil if indexMCP is not found
        guard let indexMCPPoint = points[.indexMCP] else {
            return nil
        }
        
        // HOW COULD I ITERATE THRU INDEX, MIDDLE, AND LITTLE TO AVOID COPYING AND PASTING THESE THREE LINES?
        var dx = (points[.thumbTip]?.location.x ?? 0.0) - (points[.indexTip]?.location.x ?? 0.0)
        var dy = (points[.thumbTip]?.location.x ?? 0.0) - (points[.indexTip]?.location.x ?? 0.0)
        
        // the distance from the thumb tip to the index tip
        let distanceTP = hypot(dx, dy)
        
        let dm = (points[.thumbTip]?.location.x ?? 0.0) - (points[.middleTip]?.location.x ?? 0.0)
        let dn = (points[.thumbTip]?.location.x ?? 0.0) - (points[.middleTip]?.location.x ?? 0.0)
        
        // the distance from the thumb tip to the middle tip
        let distanceTM = hypot(dm, dn)
        
        dx = (points[.thumbTip]?.location.x ?? 0.0) - (points[.littleTip]?.location.x ?? 0.0)
        dy = (points[.thumbTip]?.location.x ?? 0.0) - (points[.littleTip]?.location.x ?? 0.0)
        
        // the distance from the thumb tip to the pinky tip
        let distanceTL = hypot(dx, dy)
        
        // arbitrary scaling to my hand
        return Hand(x: Double(1.1 - indexMCPPoint.location.y * 1.2), y: Double(1.2 - indexMCPPoint.location.x * 1.4), p: distanceTP * 2.3 - 0.1, m: distanceTM * 2.0 - 0.1, l: distanceTL * 1.7 - 0.1)
    }
    
}
