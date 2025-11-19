//
//  HandBuffer.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/14/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import AVFoundation

struct BufferHand {
    var measured = Hand()
    var filtered = Hand()
    var time = Date()
    
    init(h: Hand = Hand(), t: Date = Date()) {
        measured = h
        filtered = h
        time = t
    }

}

// ring buffer implementation inspired by https://www.youtube.com/watch?v=KyreJSKEagg
class HandBuffer {
    
    private let filter = EMAFilter()
    private var data = [BufferHand]()
    private var headPtr = 0
    private var beatHeadPtr = 0
    // in case I want to try using a lagging head to compare some ahead-values
    private var processPtr = 0
    private var capacity = Int()
    private let parameters = Parameters()
    
    init(capacity: Int) {
        self.capacity = capacity
        // allow for O(1) cause we know the size the buffer needs to be (no resizing)
        data.reserveCapacity(_:capacity)
        data.reserveCapacity(parameters.handCapacity)
    }
    
    public func clear() {
        data.removeAll()
        headPtr = 0
    }
    
    // revised ring buffer var names and array arithmetic with Copilot
    public func addElement(current: BufferHand) -> BufferHand {
        var h = current
        guard capacity > 0 else { return h }
        
        // if empty initialize one element without filtering or calculating velocity or acceleration and return so velocity can be calculated next
        if data.isEmpty {
            self.data.append(h)
            headPtr = data.count % capacity
            return h
        }
        
        // index of previous element
        let lastIndex = (headPtr - 1 + data.count) % data.count
        let prev = data[lastIndex]
        
        // apply filter
        let f = filterHand(value: h.measured, previousValue: h.filtered, weight: parameters.handFilterWeight)
        
        // shifting around the insertion point instead of all the elements in the array
        headPtr = (headPtr + 1) % capacity
        
        // for some reason appending and replacing are different methods
        if (data.count < capacity) {
            self.data.append(h)
        } else {
            self.data[headPtr] = h
        }
        
        return h
    }
    
    public func filterHand(value: Hand, previousValue: Hand, weight: Double) -> Hand {
        let a = value
        let b = previousValue
        var c = Hand()
        
        c.mcpX = filter.applyFilter(value: a.mcpX, previousValue: b.mcpX, weight: weight)
        c.mcpY = filter.applyFilter(value: a.mcpY, previousValue: b.mcpY, weight: weight)
        c.distanceTP = filter.applyFilter(value: a.distanceTP, previousValue: b.distanceTP, weight: weight)
        c.closedness = filter.applyFilter(value: a.closedness, previousValue: b.closedness, weight: weight)
        
        return c
    }
    
}
