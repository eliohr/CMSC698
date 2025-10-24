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
    var filteredTimeInterval = Double()
    var velocity = CGVector()
    var filteredAcceleration = CGVector()
    var accelerationDouble = Double()
    var beatCandidate = false // acceleration has crossed and returned from threshold
    var isBeat = false // acceleration over the threshold for the longest time of any beat candidates within the tempo range
    var isDownbeat = false // y-maximum was reached (this stays on until another beat is detected so there will be many non-beat downbeats but they won't be members of the final beat-only buffer)
    
    init(point: CGPoint = CGPoint(), time: Date = Date()) {
        self.measuredPoint = point
        self.filteredPoint = point
        self.time = time
        self.filteredTimeInterval = 0.0
        self.velocity = .zero
        self.filteredAcceleration = .zero
        self.accelerationDouble = 0.0
    }

}

// ring buffer implementation inspired by https://www.youtube.com/watch?v=KyreJSKEagg
class BeatBuffer {
    
    private var data = [BufferPoint]()
    private var headPtr = 0
    private var beatHeadPtr = 0
    // in case I want to try using a lagging head to compare some ahead-values
    private var processPtr = 0
    private var capacity = Int()
    private let parameters = Parameters()
    
    private var beats = [BufferPoint]()
    private var tempo = Tempo(bpm: 120, meter: 4, beat: 1)
    
    init(capacity: Int) {
        self.capacity = capacity
        // allow for O(1) cause we know the size the buffer needs to be (no resizing)
        data.reserveCapacity(_:capacity)
        data.reserveCapacity(parameters.beatsCapacity)
    }
    
    public func clear() {
        data.removeAll()
        headPtr = 0
    }
    
    // revised ring buffer var names and array arithmetic with Copilot
    public func addPoint(currentPoint: BufferPoint) -> BufferPoint {
        var p = currentPoint
        guard capacity > 0 else { return p }
        
        // if empty initialize one element without filtering or calculating velocity or acceleration and return so velocity can be calculated next
        if data.isEmpty {
            self.data.append(p)
            headPtr = data.count % capacity
            return p
        }
        
        // index of previous element
        let lastIndex = (headPtr - 1 + data.count) % data.count
        let prev = data[lastIndex]
        
        // calculate time interval—copilot suggested /0 safeguard
        let dt = max(1e-6, p.time.timeIntervalSince(prev.time))
        p.filteredTimeInterval = applyFilter(value: dt, previousValue: prev.filteredTimeInterval, weight: parameters.timeFilterWeight)
        
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
        p.accelerationDouble = sqrt(fddx*fddx + fddy*fddy)
        
        // shifting around the insertion point instead of all the elements in the array
        headPtr = (headPtr + 1) % capacity
        
        // for some reason appending and replacing are different methods
        if (data.count < capacity) {
            self.data.append(p)
        } else {
            self.data[headPtr] = p
        }
        
        detectBeats()
        calculateTempo()
        
        return p
    }
    
    var thresholdEntryTime = Date()
    var accelerationThresholdCrossed = false
    
    public func detectBeats() {
        
        var p = data[(headPtr - 1 + capacity) % capacity]
        
        if p.velocity.dy == 0 {
            p.isDownbeat = true
        }
        
        // if the acceleration threshold is crossed for longer than the required time, the point of exit is flagged as a beat candidate - copilot assistance
        if p.accelerationDouble > parameters.accelerationThreshold {
            if !accelerationThresholdCrossed {
                accelerationThresholdCrossed = true
                thresholdEntryTime = p.time
            }
        } else {
            if accelerationThresholdCrossed {
                let timeAboveThreshold = p.time.timeIntervalSince(thresholdEntryTime)
                if timeAboveThreshold > parameters.timeIntervalThreshold {
                    p.beatCandidate = true
                }
                accelerationThresholdCrossed = false
            }
        }
        
        // for now, all beat candidates are beats
        if p.beatCandidate { p.isBeat = true }
        
        if p.isBeat {
            
            debugBeatDetection()
            
            if beats.isEmpty {
                self.beats.append(p)
                beatHeadPtr = beats.count % capacity
                return
            }
            
            // shifting around the insertion point instead of all the elements in the array
            beatHeadPtr = (beatHeadPtr + 1) % parameters.beatsCapacity
            
            // for some reason appending and replacing are different methods
            if (beats.count < parameters.beatsCapacity) {
                self.beats.append(p)
            } else {
                self.beats[beatHeadPtr] = p
            }
        }
        
    }
    
    public func calculateTempo() {
        
    }
    
    // copilot: debug method to check beat detection state
    public func debugBeatDetection() {
        print("Beat detection state:")
        print("- accelerationThresholdCrossed: \(accelerationThresholdCrossed)")
        print("- thresholdEntryTime: \(thresholdEntryTime)")
        print("- beats count: \(beats.count)")
        print("- accelerationThreshold: \(parameters.accelerationThreshold)")
        print("- timeIntervalThreshold: \(parameters.timeIntervalThreshold)")
    }
    
    // I learned about the EMA filter using this video https://www.youtube.com/watch?v=iPYacJZM5Z0
    public func applyFilter(value: Double, previousValue: Double, weight: Double) -> Double {
        let filteredValue = ((1.0 - weight) * value + weight * previousValue)
        return filteredValue
    }
    
    public func getTempo() -> (Tempo) {
        return self.tempo
    }
    
    /*
     public func getTempo(buffer: BeatBuffer) -> (Tempo) {
     
     
     
     
     let helloWorld = Tempo(bpm: 120.0, meter: 4, beat: 1)
     return (helloWorld)
     
     }
     */
}
