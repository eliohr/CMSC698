//
//  HandBuffer.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/14/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import AVFoundation

public struct Hand {
    var mcpX = Double()
    var mcpY = Double()
    var distanceTP = Double()
    var distanceTM = Double()
    var distanceTL = Double()
    
    init(x: Double = Double(), y: Double = Double(), p: Double = Double(), m: Double = Double(), l: Double = Double()) {
        mcpX = x
        mcpY = y
        distanceTP = p
        distanceTM = m
        distanceTL = l
    }
    
    func getValue(for key: HandAttribute) -> Double {
        switch key {
        case .mcpX:
            return self.mcpX
        case .mcpY:
            return self.mcpY
        case .distanceTP:
            return self.distanceTP
        case .distanceTM:
            return self.distanceTM
        case .distanceTL:
            return self.distanceTL
        }
    }
    
    public func filterHand(previousValue: Hand, weight: Double) -> Hand {
        let a = self
        let b = previousValue
        var c = Hand()
        let filter = EMAFilter()
        
        c.mcpX = filter.applyFilter(value: a.mcpX, previousValue: b.mcpX, weight: weight)
        c.mcpY = filter.applyFilter(value: a.mcpY, previousValue: b.mcpY, weight: weight)
        c.distanceTP = filter.applyFilter(value: a.distanceTP, previousValue: b.distanceTP, weight: weight)
        c.distanceTM = filter.applyFilter(value: a.distanceTM, previousValue: b.distanceTM, weight: weight)
        c.distanceTL = filter.applyFilter(value: a.distanceTL, previousValue: b.distanceTL, weight: weight)

        return c
    }
}
