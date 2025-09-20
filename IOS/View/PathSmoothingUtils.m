// Created by OpenWorkoutTracker on 2025-08-27.
// Copyright (c) 2025 Michael J. Simms. All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "PathSmoothingUtils.h"

@implementation PathSmoothingUtils

+ (NSArray<NSValue*>*)smoothCoordinates:(CLLocationCoordinate2D*)coordinates 
                             pointCount:(NSUInteger)pointCount 
                         smoothingFactor:(CGFloat)smoothingFactor
{
    if (pointCount < 3 || smoothingFactor <= 0.0) {
        // Not enough points for smoothing or no smoothing requested
        NSMutableArray* result = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < pointCount; i++) {
            [result addObject:[NSValue valueWithMKCoordinate:coordinates[i]]];
        }
        return result;
    }
    
    NSMutableArray* smoothedPoints = [[NSMutableArray alloc] init];
    
    // Always add the first point
    [smoothedPoints addObject:[NSValue valueWithMKCoordinate:coordinates[0]]];
    
    // Apply smoothing to intermediate points
    for (NSUInteger i = 1; i < pointCount - 1; i++) {
        CLLocationCoordinate2D prev = coordinates[i - 1];
        CLLocationCoordinate2D current = coordinates[i];
        CLLocationCoordinate2D next = coordinates[i + 1];
        
        // Calculate smoothed position using weighted average
        CLLocationDegrees smoothedLat = current.latitude + 
            smoothingFactor * 0.5 * ((prev.latitude + next.latitude) / 2.0 - current.latitude);
        CLLocationDegrees smoothedLon = current.longitude + 
            smoothingFactor * 0.5 * ((prev.longitude + next.longitude) / 2.0 - current.longitude);
        
        CLLocationCoordinate2D smoothedCoord = CLLocationCoordinate2DMake(smoothedLat, smoothedLon);
        [smoothedPoints addObject:[NSValue valueWithMKCoordinate:smoothedCoord]];
    }
    
    // Always add the last point
    [smoothedPoints addObject:[NSValue valueWithMKCoordinate:coordinates[pointCount - 1]]];
    
    return smoothedPoints;
}

@end
