// Created by OpenWorkoutTracker on 2025-08-27.
// Copyright (c) 2025 Michael J. Simms. All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import <UIKit/UIKit.h>
#import "CrumbPathRenderer.h"

@interface SmoothedCrumbPathRenderer : CrumbPathRenderer

// Smoothing factor (0.0 = no smoothing, 1.0 = maximum smoothing)
@property (nonatomic, assign) CGFloat smoothingFactor;

@end
