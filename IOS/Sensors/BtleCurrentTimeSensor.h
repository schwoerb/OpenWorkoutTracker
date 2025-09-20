// Created by Bradley Schwoerer on 8/26/25.
// Copyright (c) 2025 Bradley Schwoerer All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>

#import "BluetoothServices.h"
#import "BtleSensor.h"

// Subscribe to the notification with this name to receive updates.
#define NOTIFICATION_NAME_CURRENT_TIME       "CurrentTimeUpdated"

// Keys for the dictionary associated with the notification.
#define KEY_NAME_CURRENT_TIME                "CurrentTime"
#define KEY_NAME_LOCAL_TIME_INFO             "LocalTimeInfo"
#define KEY_NAME_REFERENCE_TIME_INFO         "ReferenceTimeInfo"
#define KEY_NAME_CURRENT_TIME_TIMESTAMP_MS   "Time"
#define KEY_NAME_CURRENT_TIME_PERIPHERAL_OBJ "Peripheral"

@interface BtleCurrentTimeSensor : BtleSensor
{
	NSDate*   currentTime;
	int8_t    timeZoneOffset;
	uint8_t   dstOffset;
	uint8_t   timeSource;
	uint8_t   timeAccuracy;
	uint8_t   daysSinceUpdate;
	uint8_t   hoursSinceUpdate;
}

- (SensorType)sensorType;

- (void)enteredBackground;
- (void)enteredForeground;

- (void)startUpdates;
- (void)stopUpdates;
- (void)update;

// Current Time Service methods
- (NSDate*)getCurrentTime;
- (void)setCurrentTime:(NSDate*)newTime;
- (void)requestTimeUpdate;

@end
