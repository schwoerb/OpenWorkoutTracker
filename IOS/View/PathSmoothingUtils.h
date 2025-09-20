// Created by OpenWorkoutTracker on 2025-08-27.
// Copyright (c) 2025 Michael J. Simms. All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PathSmoothingUtils : NSObject

+ (NSArray<NSValue*>*)smoothCoordinates:(CLLocationCoordinate2D*)coordinates 
                             pointCount:(NSUInteger)pointCount 
                         smoothingFactor:(CGFloat)smoothingFactor;

@end
