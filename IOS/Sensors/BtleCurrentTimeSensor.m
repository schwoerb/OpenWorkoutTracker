// Created by Bradley Schwoerer on 8/26/25.
// Copyright (c) 2025 Bradley Schwoerer All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "BtleCurrentTimeSensor.h"
#import "BtleDiscovery.h"

// Current Time characteristic flags
#define CT_FLAGS_MANUAL_TIME_UPDATE     0x01
#define CT_FLAGS_EXTERNAL_REF_TIME      0x02
#define CT_FLAGS_CHANGE_OF_TIME_ZONE    0x04
#define CT_FLAGS_CHANGE_OF_DST          0x08

// Time Source values
#define TIME_SOURCE_UNKNOWN             0x00
#define TIME_SOURCE_NETWORK_TIME        0x01
#define TIME_SOURCE_GPS                 0x02
#define TIME_SOURCE_RADIO_TIME_SIGNAL   0x03
#define TIME_SOURCE_MANUAL              0x04
#define TIME_SOURCE_ATOMIC_CLOCK        0x05
#define TIME_SOURCE_CELLULAR_NETWORK    0x06

typedef struct CurrentTimeData
{
	uint16_t year;
	uint8_t  month;
	uint8_t  day;
	uint8_t  hours;
	uint8_t  minutes;
	uint8_t  seconds;
	uint8_t  dayOfWeek;
	uint8_t  fractions256;
	uint8_t  adjustReason;
} __attribute__((packed)) CurrentTimeData;

typedef struct LocalTimeInformation
{
	int8_t  timeZone;
	uint8_t dstOffset;
} __attribute__((packed)) LocalTimeInformation;

typedef struct ReferenceTimeInformation
{
	uint8_t timeSource;
	uint8_t timeAccuracy;
	uint8_t daysSinceUpdate;
	uint8_t hoursSinceUpdate;
} __attribute__((packed)) ReferenceTimeInformation;

@implementation BtleCurrentTimeSensor

#pragma mark init methods

- (id)init
{
	self = [super init];
	if (self)
	{
		self->currentTime = [NSDate date];
		self->timeZoneOffset = 0;
		self->dstOffset = 0;
		self->timeSource = TIME_SOURCE_UNKNOWN;
		self->timeAccuracy = 0;
		self->daysSinceUpdate = 0;
		self->hoursSinceUpdate = 0;
	}
	return self;
}

#pragma mark characteristics methods

- (SensorType)sensorType
{
	return SENSOR_TYPE_UNKNOWN; // Add SENSOR_TYPE_CURRENT_TIME to SensorType enum if needed
}

- (void)enteredBackground
{
}

- (void)enteredForeground
{
}

- (void)startUpdates
{	
}

- (void)stopUpdates
{
}

- (void)update
{
}

#pragma mark Current Time Service methods

- (NSDate*)getCurrentTime
{
	return self->currentTime;
}

- (void)setCurrentTime:(NSDate*)newTime
{
	if (newTime)
	{
		self->currentTime = newTime;
		
		// Notify observers of time update
		NSDictionary* timeData = [[NSDictionary alloc] initWithObjectsAndKeys:
								  self->currentTime, @KEY_NAME_CURRENT_TIME,
								  [NSNumber numberWithLongLong:[self currentTimeInMs]], @KEY_NAME_CURRENT_TIME_TIMESTAMP_MS,
								  self->peripheral, @KEY_NAME_CURRENT_TIME_PERIPHERAL_OBJ,
								  nil];
		if (timeData)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@NOTIFICATION_NAME_CURRENT_TIME object:timeData];
		}
	}
}

- (void)requestTimeUpdate
{
	// Request time update from the peripheral if connected
	if (self->peripheral && self->peripheral.state == CBPeripheralStateConnected)
	{
		// Find the Current Time service and request an update
		for (CBService* service in self->peripheral.services)
		{
			if ([self serviceEquals:service withServiceId:BT_SERVICE_CURRENT_TIME])
			{
				for (CBCharacteristic* characteristic in service.characteristics)
				{
					if ([super characteristicEquals:characteristic withBTChar:BT_CHARACTERISTIC_CURRENT_TIME])
					{
						[self->peripheral readValueForCharacteristic:characteristic];
						break;
					}
				}
				break;
			}
		}
	}
}

#pragma mark CBPeripheral methods

- (void)updateWithCurrentTimeData:(NSData*)data
{
	if (data && data.length >= sizeof(CurrentTimeData))
	{
		const CurrentTimeData* timeData = [data bytes];
		
		if (timeData)
		{
			// Convert BLE time format to NSDate
			NSDateComponents* components = [[NSDateComponents alloc] init];
			components.year = CFSwapInt16LittleToHost(timeData->year);
			components.month = timeData->month;
			components.day = timeData->day;
			components.hour = timeData->hours;
			components.minute = timeData->minutes;
			components.second = timeData->seconds;
			
			NSCalendar* calendar = [NSCalendar currentCalendar];
			NSDate* newTime = [calendar dateFromComponents:components];
			
			if (newTime)
			{
				[self setCurrentTime:newTime];
			}
		}
	}
}

- (void)updateWithLocalTimeInfo:(NSData*)data
{
	if (data && data.length >= sizeof(LocalTimeInformation))
	{
		const LocalTimeInformation* localTimeInfo = [data bytes];
		
		if (localTimeInfo)
		{
			self->timeZoneOffset = localTimeInfo->timeZone;
			self->dstOffset = localTimeInfo->dstOffset;
			
			// Notify observers of local time info update
			NSDictionary* localTimeData = [[NSDictionary alloc] initWithObjectsAndKeys:
										   [NSNumber numberWithChar:self->timeZoneOffset], @"TimeZoneOffset",
										   [NSNumber numberWithUnsignedChar:self->dstOffset], @"DSTOffset",
										   [NSNumber numberWithLongLong:[self currentTimeInMs]], @KEY_NAME_CURRENT_TIME_TIMESTAMP_MS,
										   self->peripheral, @KEY_NAME_CURRENT_TIME_PERIPHERAL_OBJ,
										   nil];
			if (localTimeData)
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:@NOTIFICATION_NAME_CURRENT_TIME object:localTimeData];
			}
		}
	}
}

- (void)updateWithReferenceTimeInfo:(NSData*)data
{
	if (data && data.length >= sizeof(ReferenceTimeInformation))
	{
		const ReferenceTimeInformation* refTimeInfo = [data bytes];
		
		if (refTimeInfo)
		{
			self->timeSource = refTimeInfo->timeSource;
			self->timeAccuracy = refTimeInfo->timeAccuracy;
			self->daysSinceUpdate = refTimeInfo->daysSinceUpdate;
			self->hoursSinceUpdate = refTimeInfo->hoursSinceUpdate;
			
			// Notify observers of reference time info update
			NSDictionary* refTimeData = [[NSDictionary alloc] initWithObjectsAndKeys:
										 [NSNumber numberWithUnsignedChar:self->timeSource], @"TimeSource",
										 [NSNumber numberWithUnsignedChar:self->timeAccuracy], @"TimeAccuracy",
										 [NSNumber numberWithUnsignedChar:self->daysSinceUpdate], @"DaysSinceUpdate",
										 [NSNumber numberWithUnsignedChar:self->hoursSinceUpdate], @"HoursSinceUpdate",
										 [NSNumber numberWithLongLong:[self currentTimeInMs]], @KEY_NAME_CURRENT_TIME_TIMESTAMP_MS,
										 self->peripheral, @KEY_NAME_CURRENT_TIME_PERIPHERAL_OBJ,
										 nil];
			if (refTimeData)
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:@NOTIFICATION_NAME_CURRENT_TIME object:refTimeData];
			}
		}
	}
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
	if ([self serviceEquals:service withServiceId:BT_SERVICE_CURRENT_TIME])
	{
		for (CBCharacteristic* aChar in service.characteristics)
		{
			if ([super characteristicEquals:aChar withBTChar:BT_CHARACTERISTIC_CURRENT_TIME])
			{
				// Subscribe to notifications and read current value
				[self->peripheral setNotifyValue:YES forCharacteristic:aChar];
				[self->peripheral readValueForCharacteristic:aChar];
			}
			else if ([super characteristicEquals:aChar withBTChar:BT_CHARACTERISTIC_LOCAL_TIME_INFORMATION])
			{
				// Read local time information
				[self->peripheral readValueForCharacteristic:aChar];
			}
			else if ([super characteristicEquals:aChar withBTChar:BT_CHARACTERISTIC_REFERENCE_TIME_INFORMATION])
			{
				// Read reference time information
				[self->peripheral readValueForCharacteristic:aChar];
			}
		}
		[super handleCharacteristicForService:service];
	}
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
	if (characteristic == nil)
	{
		return;
	}
	if (!characteristic.value)
	{
		return;
	}
	if (error)
	{
		return;
	}

	if ([super characteristicEquals:characteristic withBTChar:BT_CHARACTERISTIC_CURRENT_TIME])
	{
		[self updateWithCurrentTimeData:characteristic.value];
	}
	else if ([super characteristicEquals:characteristic withBTChar:BT_CHARACTERISTIC_LOCAL_TIME_INFORMATION])
	{
		[self updateWithLocalTimeInfo:characteristic.value];
	}
	else if ([super characteristicEquals:characteristic withBTChar:BT_CHARACTERISTIC_REFERENCE_TIME_INFORMATION])
	{
		[self updateWithReferenceTimeInfo:characteristic.value];
	}
	else if ([super characteristicEquals:characteristic withBTChar:BT_CHARACTERISTIC_BATTERY_LEVEL])
	{
		[super checkBatteryLevel:characteristic.value];
	}
}

- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
	// Handle write confirmations if needed
}

@end
