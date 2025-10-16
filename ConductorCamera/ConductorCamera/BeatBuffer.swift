//
//  PeakBuffer.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/7/25.
//  Copyright © 2025 Apple. All rights reserved.
//
//  ring buffer implementation inspired by https://www.youtube.com/watch?v=KyreJSKEagg
/*
import UIKit
import AVFoundation

class BeatBuffer {
    
    var data = [BufferPoint]()
    var size = 0
    // some silly lower-level-looking logic for reducing processing speed
    var headPtr = 0
    var capacity = Int()
    
    init(capacity: Int) {
        self.capacity = capacity
        // allow for O(1) cause we know the size the buffer needs to be (no resizing)
        data.reserveCapacity(_:capacity)
    }
    
    public func reset() {
        
    }
    
    public func clear() {
        data.removeAll()
        var size = 0
        var headPtr = 0
    }
    
    public func addPoint(point: BufferPoint) {
        size+=1
        while(size>=capacity) {
            data.remove(at: headPtr)
            size-=1
        }
        // shifting around the insertion point instead of all the elements in the array
        headPtr+=1
        data.insert(point, at: headPtr)
        process()
        return
    }
    
    public func head(h: Int) -> BufferPoint {
        return data[h]
    }
    
    public func process() {
        for (index, point) in data.enumerated() {
            var previous = BufferPoint()
            previous = data[index-1]
            
            point.updateCalculatedValues(velocity: <#T##CGVector#>, acceleration: <#T##CGVector#>)
        }
    }
    
    public func getTempo() -> (Double, Int, Int) {
        // tempo, meter, beat
        return (120.0, 4, 1)
        
    }

    
}
*/
