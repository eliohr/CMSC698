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
    var closedness = Double()
    
    init(x: Double = Double(), y: Double = Double(), d: Double = Double(), c: Double = Double()) {
        mcpX = x
        mcpY = y
        distanceTP = d
        closedness = c
    }
    
    func getValue(for key: HandAttribute) -> Double {
        switch key {
        case .mcpX:
            return self.mcpX
        case .mcpY:
            return self.mcpY
        case .distanceTP:
            return self.distanceTP
        case .closedness:
            return self.closedness
        }
    }
    
    public func filterHand(currentValue: Hand, previousValue: Hand, weight: Double) -> Hand {
        let a = currentValue
        let b = previousValue
        var c = Hand()
        let filter = EMAFilter()
        
        c.mcpX = filter.applyFilter(value: a.mcpX, previousValue: b.mcpX, weight: weight)
        c.mcpY = filter.applyFilter(value: a.mcpY, previousValue: b.mcpY, weight: weight)
        c.distanceTP = filter.applyFilter(value: a.distanceTP, previousValue: b.distanceTP, weight: weight)
        c.closedness = filter.applyFilter(value: a.closedness, previousValue: b.closedness, weight: weight)
        
        return c
    }
}
