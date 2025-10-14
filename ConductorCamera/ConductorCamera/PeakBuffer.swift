//
//  PeakBuffer.swift
//  HandPose
//
//  Created by Eli Hooker Reese on 10/7/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import AVFoundation

class PeakBuffer {
    
    func reset() {
        
    }
    
    func addPoint(point: BufferPoint) {
        return
    }
    
}
    
/*
Recommended Data Structure: Circular Buffer
A Circular Buffer is ideal for this because it models a fixed-size queue that overwrites the oldest data when it becomes full, which perfectly matches the "last 5 seconds" requirement without costly memory shuffling.

1. Implementation Details
You'll be storing time-stamped hand data. Each element in the buffer should be a simple struct or object containing:

Data Point={Timestamp (t),Y-coordinate (y)}
The buffer size (N) is determined by your target frame rate (FPS) and the required window duration (W):

N=FPS×W
For example, at 60 FPS with a 5-second window: N=60×5=300 data points.

2. Advantages of a Circular Buffer
Feature    Benefit for Peak Detection
Fixed Size    Guarantees the data set only represents the exact 5-second window, simplifying the logic.
Efficient Insertion    O(1) complexity. A new point is added simply by overwriting the index pointer (a write-only operation).
Efficient Deletion    O(1) complexity. The oldest data is implicitly discarded when the pointer wraps around, avoiding costly memory shifts.
Fast Iteration    O(N) complexity. You can quickly iterate over the fixed window of data for the peak detection algorithm.
Peak Detection Algorithm & Data Reference
The goal of your peak detection algorithm is to find local maxima (the highest point) in the Y-coordinate data stream, which correspond to the conductor's upstroke/release.

1. Storing Raw Data
You should store the raw Y-coordinate data from your pose estimation because the "peak" is defined by this position.

2. Smoothing/Filtering
Before applying peak detection, you should iterate over the raw data in the buffer and compute a smoothed Y-coordinate, or perhaps the velocity/acceleration, and store that as well (or in a secondary buffer).

Why velocity/acceleration? The beat is often clearer in the acceleration data (the sudden stop/change of direction at the peak) than in the raw position data.

Raw Data: Y
t
​
 

Velocity: V
t
​
 ≈(Y
t
​
 −Y
t−1
​
 )/(t−t
t−1
​
 )

Acceleration: A
t
​
 ≈(V
t
​
 −V
t−1
​
 )/(t−t
t−1
​
 )

3. Peak Detection Logic
Your peak detection logic would iterate through the 300 points in the buffer, looking for a point (P
i
​
 ) that satisfies the following conditions:

P
i
​
 .Y>P
i−k
​
 .Y (for all points in a small preceding window k)
AND
P
i
​
 .Y>P
i+k
​
 .Y (for all points in a small succeeding window k)
AND
P
i
​
  must also cross a minimum height/velocity threshold.
The 5-second window provides enough data to confirm the detected peak is a genuine, rhythmic beat and to calculate a stable tempo based on the time between the last several confirmed peaks.

 */
