//
//  PeakBuffer.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 10/7/25.
//  Copyright © 2025 Apple. All rights reserved.
//  

import UIKit
import AVFoundation

// might put this inside a different class more relevant to actually generating the midi signal but I'm not nearly that far along yet
struct Tempo {
    var bpm = Double()
    var meter = Int()
    var beat = Int()
    
    init(bpm: Double, meter: Int, beat:Int) {
        self.bpm = bpm
        self.meter = meter
        self.beat = beat
    }
}

// Gemini suggested the velocity and acceleration variables all be stored here
struct BufferPoint {
    var measuredPoint = CGPoint()
    var filteredPoint = CGPoint()
    var time = Date()
    var velocity = CGVector()
    var filteredAcceleration = CGVector()
    var isBeat = false
    var isDownbeat = false
    
    init(point: CGPoint = CGPoint(), time: Date = Date()) {
        self.measuredPoint = point
        self.filteredPoint = point
        self.time = time
        self.velocity = .zero
        self.filteredAcceleration = .zero
    }

}

// ring buffer implementation inspired by https://www.youtube.com/watch?v=KyreJSKEagg
class BeatBuffer {
    
    var data = [BufferPoint]()
    // some silly lower-level-looking logic for reducing processing speed
    var headPtr = 0
    var capacity = Int()
    private let parameters = Parameters() // Create Parameters instance once
    
    init(capacity: Int) {
        self.capacity = capacity
        // allow for O(1) cause we know the size the buffer needs to be (no resizing)
        data.reserveCapacity(_:capacity)
    }
    
    /* public func reset() {
        
    } */
    
    public func clear() {
        data.removeAll()
        headPtr = 0
    }
    
    // revised ring buffer var names and array arithmetic with Copilot
    public func addPoint(currentPoint: BufferPoint) {
        var p = currentPoint
        guard capacity > 0 else { return }
        
        // if empty initialize one element without filtering or calculating velocity or acceleration and return so velocity can be calculated next
        if data.isEmpty {
            self.data.append(p)
            headPtr = data.count % capacity
            return
        }
        
        // index of previous element
        let lastIndex = (headPtr - 1 + data.count) % data.count
        let prev = data[lastIndex]
        
        // calculate time interval—copilot suggested /0 safeguard
        let dt = max(1e-6, p.time.timeIntervalSince(prev.time))
        
        // apply stronger filter to points
        let fx = applyFilter(value: p.measuredPoint.x, previousValue: prev.filteredPoint.x, weight: parameters.pointFilterWeight)
        let fy = applyFilter(value: p.measuredPoint.y, previousValue: prev.filteredPoint.y, weight: parameters.pointFilterWeight)
        
        // Gemini helped me with some syntax here (how to get differences in date objects and initialize cgvectors)
        
        // calculate position change (velocity)
        let dx = (fx - prev.filteredPoint.x)/dt
        let dy = (fy - prev.filteredPoint.y)/dt
        
        // calculate velocity change (acceleration)
        let ddx = (dx - prev.velocity.dx)/dt
        let ddy = (dy - prev.velocity.dy)/dt
        
        // apply weaker filter to accelerations
        let fddx = applyFilter(value: ddx, previousValue: prev.filteredAcceleration.dx, weight: parameters.accelerationFilterWeight)
        let fddy = applyFilter(value: ddy, previousValue: prev.filteredAcceleration.dy, weight: parameters.accelerationFilterWeight)

        // assign velocity and acceleration vectors to nextPoint as well as the filtered point so the next value can depend on the current filtered value
        p.filteredPoint = CGPoint(x: fx, y: fy)
        p.velocity = CGVector(dx: dx, dy: dy)
        p.filteredAcceleration = CGVector(dx: fddx, dy: fddy)
        
        // shifting around the insertion point instead of all the elements in the array
        headPtr = (headPtr + 1) % capacity

        // for some reason appending and replacing are different methods
        if (data.count < capacity) {
            self.data.append(p)
        } else {
            self.data[headPtr] = p
        }

        return
    }
    
    // I learned about the EMA filter using this video https://www.youtube.com/watch?v=iPYacJZM5Z0
    public func applyFilter(value: Double, previousValue: Double, weight: Double) -> Double {
        return ((1.0 - weight) * value + weight * previousValue)
    }
    
    public func head(h: Int) -> BufferPoint {
        return data[h]
    }
    
    public func getTempo() -> (Tempo) {
        // insert actual tempo determination logic here
        let helloWorld = Tempo(bpm: 120.0, meter: 4, beat: 1)
        return (helloWorld)
        
    }

    
}
