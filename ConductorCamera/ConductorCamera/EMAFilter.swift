//
//  EMAFilter.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/18/25.
//  Copyright © 2025 Apple. All rights reserved.
//

// I learned about the EMA filter using this video https://www.youtube.com/watch?v=iPYacJZM5Z0
public class EMAFilter {
    public func applyFilter(value: Double, previousValue: Double, weight: Double) -> Double {
        let filteredValue = ((1.0 - weight) * value + weight * previousValue)
        return filteredValue
    }
}
