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

//  Gemini suggested the velocity and acceleration variables all be stored here
struct BufferPoint {
    var rawPoint = CGPoint()
    var time = Date()
    var velocity = CGVector()
    var acceleration = CGVector()
    var isBeat = false
    var isDownbeat = false
    
    init(point: CGPoint = CGPoint(), time: Date = Date()) {
        self.rawPoint = point
        self.time = time
    }

}

// ring buffer implementation inspired by https://www.youtube.com/watch?v=KyreJSKEagg
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
    
    public func addPoint(nextPoint: BufferPoint) {
        var nextPoint = nextPoint
        size+=1
        while(size>=capacity) {
            data.remove(at: headPtr)
            size-=1
        }
        
        let currentOptional: BufferPoint? = data[headPtr-1]
        guard let currentUnfilteredPoint = currentOptional else { return }
        
        // apply stronger filter to points
        let currentPoint = BufferPoint(point: CGPoint(x: applyFilter(value: currentUnfilteredPoint.rawPoint.x, previousValue: nextPoint.rawPoint.x, weight: Parameters().pointFilterWeight), y: applyFilter(value: currentUnfilteredPoint.rawPoint.y, previousValue: nextPoint.rawPoint.y, weight: Parameters().pointFilterWeight)), time: currentUnfilteredPoint.time)
        
        // Gemini helped me with some syntax here (how to get differences in date objects and initialize cgvectors)
        
        // calculate time interval
        let dt = nextPoint.time.timeIntervalSince(currentPoint.time)
        
        // calculate position change
        let dx = nextPoint.rawPoint.x - currentPoint.rawPoint.x
        let dy = nextPoint.rawPoint.y - currentPoint.rawPoint.y

        // calculate velocity change
        let ddx = nextPoint.velocity.dx - currentPoint.velocity.dx
        let ddy = nextPoint.velocity.dy - currentPoint.velocity.dy
        
        // apply weaker filter to accelerations
        
        // shifting around the insertion point instead of all the elements in the array
        headPtr+=1
        data.insert(nextPoint, at: headPtr)
        
        
        return
    }
    
    // I learned about the EMA filter using this video https://www.youtube.com/watch?v=iPYacJZM5Z0
    public func applyFilter(value: Double, previousValue: Double, weight: Double) -> Double {
        return (weight*value-(1-weight)*value)
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
