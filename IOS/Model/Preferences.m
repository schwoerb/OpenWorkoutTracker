// Created by Michael Simms on 7/17/12.
// Copyright (c) 2012 Michael J. Simms. All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "Preferences.h"

///
/// The names of the preferences as stored in the plist file.
///

#define PREF_NAME_UUID                                  "UUID"
#define PREF_NAME_UNITS                                 "Units"
#define PREF_NAME_AUTOSCALE_MAP                         "Autoscale Map"
#define PREF_NAME_SMOOTH_PATHS                          "Smooth Paths"
#define PREF_NAME_SCAN_FOR_SENSORS                      "Scan for Sensors"
#define PREF_NAME_BROADCAST_TO_SERVER                   "Broadcast Global"
#define PREF_NAME_BROADCAST_USER_NAME                   "Broadcast User Name"
#define PREF_NAME_BROADCAST_RATE                        "Broadcast Rate"
#define PREF_NAME_BROADCAST_PROTOCOL                    "Broadcast Protocol"
#define PREF_NAME_BROADCAST_HOST_NAME                   "Broadcast Host Name"
#define PREF_NAME_BROADCAST_SHOW_ICON                   "Broadcast Show Icon"
#define PREF_NAME_ALWAYS_CONNECT                        "Always Connect"
#define PREF_NAME_WILL_INTEGRATE_HEALTH_KIT_ACTIVITIES  "Will Integrate HealthKit Activities"
#define PREF_NAME_HIDE_HEALTH_KIT_DUPLICATES            "Hide HealthKit Duplicates"
#define PREF_NAME_HAS_SHOWN_FIRST_TIME_USE_MSG          "Has Shown First Time Use Message"
#define PREF_NAME_HAS_SHOWN_PULL_UP_HELP                "Has Shown Pull Up Help"
#define PREF_NAME_HAS_SHOWN_PUSH_UP_HELP                "Has Shown Push Up Help"
#define PREF_NAME_HAS_SHOWN_RUNNING_HELP                "Has Shown Running Help"
#define PREF_NAME_HAS_SHOWN_CYCLING_HELP                "Has Shown Cycling Help"
#define PREF_NAME_HAS_SHOWN_SQUAT_HELP                  "Has Shown Squat Help"
#define PREF_NAME_HAS_SHOWN_STATIONARY_BIKE_HELP        "Has Shown Stationary Bike Help"
#define PREF_NAME_HAS_SHOWN_TREADMILL_HELP              "Has Shown Treadmill Help"
#define PREF_NAME_USE_WATCH_HEART_RATE                  "Use Watch Heart Rate"
#define PREF_NAME_WORKOUT_GOAL                          "Workout Goal"
#define PREF_NAME_WORKOUT_GOAL_TYPE                     "Workout Goal Type"
#define PREF_NAME_WORKOUT_GOAL_DATE                     "Workout Goal Date"
#define PREF_NAME_WORKOUT_LONG_RUN_DAY                  "Workout Long Run Day"
#define PREF_NAME_WORKOUTS_CAN_INCLUDE_POOL_SWIMS       "Workouts Can Include Pool Swims"
#define PREF_NAME_WORKOUTS_CAN_INCLUDE_OPEN_WATER_SWIMS "Workouts Can Include Open Water Swims"
#define PREF_NAME_WORKOUTS_CAN_INCLUDE_BIKE_RIDES       "Workouts Can Include Bike Rides"
#define PREF_NAME_WORKOUTS_CAN_INCLUDE_RUNNING          "Workouts Can Include Running"
#define PREF_NAME_POOL_LENGTH                           "Pool Length"
#define PREF_NAME_POOL_LENGTH_UNITS                     "Pool Length Units"
#define PREF_NAME_LAST_SERVER_SYNC_TIME                 "Last Server Sync Time"

#define PREF_NAME_METRIC       "units_metric"
#define PREF_NAME_US_CUSTOMARY "units_us_customary"

///
/// Default preference values
///

#define MIN_BROADCAST_RATE     60
#define MAX_BROADCAST_RATE     5

#define DEFAULT_BROADCAST_RATE 30
#define DEFAULT_PROTOCOL       "https"
#define DEFAULT_HOST_NAME      "openworkout.cloud"
#define DEFAULT_POOL_LENGTH    MEASURE_NOT_SET

@implementation Preferences

+ (void)registerDefaultsFromSettingsBundle:(NSString*)pListName
{
	NSString* settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
	if (!settingsBundle)
	{
		return;
	}
	
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:pListName]];
	NSArray* preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
	NSMutableDictionary* defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
	for (NSDictionary* prefSpecification in preferences)
	{
		NSString* key = [prefSpecification objectForKey:@"Key"];
		if (key)
		{
			[defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

#pragma mark internal accessor methods

+ (BOOL)keyExists:(NSString*)key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil;
}

+ (BOOL)readBooleanValue:(NSString*)key
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (NSInteger)readNumericValue:(NSString*)key
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (NSString*)readStringValue:(NSString*)key
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (void)writeBoolValue:(NSString*)key withValue:(BOOL)value
{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeIntValue:(NSString*)key withValue:(NSInteger)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeDoubleValue:(NSString*)key withValue:(double)value
{
	[[NSUserDefaults standardUserDefaults] setDouble:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeStringValue:(NSString*)key withValue:(NSString*)value
{
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark get methods

+ (NSString*)uuid
{
	return [self readStringValue:@PREF_NAME_UUID];
}

+ (UnitSystem)preferredUnitSystem
{
	NSString* str = [Preferences readStringValue:@PREF_NAME_UNITS];
	if (str != nil)
	{
		if ([str compare:@PREF_NAME_US_CUSTOMARY] == 0)
			return UNIT_SYSTEM_US_CUSTOMARY;
		if ([str compare:@PREF_NAME_METRIC] == 0)
			return UNIT_SYSTEM_METRIC;
	}
	return UNIT_SYSTEM_US_CUSTOMARY;
}

+ (BOOL)shouldAutoScaleMap
{
	if ([self keyExists:@PREF_NAME_AUTOSCALE_MAP])
	{
		return [self readBooleanValue:@PREF_NAME_AUTOSCALE_MAP];
	}
	return TRUE;
}

+ (BOOL)shouldSmoothPaths
{
	if ([self keyExists:@PREF_NAME_SMOOTH_PATHS])
	{
		return [self readBooleanValue:@PREF_NAME_SMOOTH_PATHS];
	}
	return FALSE; // Default to no smoothing for backward compatibility
}

+ (BOOL)shouldScanForSensors
{
	return [self readBooleanValue:@PREF_NAME_SCAN_FOR_SENSORS];
}

+ (BOOL)shouldBroadcastToServer
{
	return [self readBooleanValue:@PREF_NAME_BROADCAST_TO_SERVER];
}

+ (NSString*)broadcastUserName
{
	return [self readStringValue:@PREF_NAME_BROADCAST_USER_NAME];
}

+ (NSInteger)broadcastRate
{
	NSInteger rate = [self readNumericValue:@PREF_NAME_BROADCAST_RATE];

	if (rate == 0)
		rate = DEFAULT_BROADCAST_RATE;
	if (rate < MAX_BROADCAST_RATE)
		rate = MAX_BROADCAST_RATE;
	if (rate > MIN_BROADCAST_RATE)
		rate = MIN_BROADCAST_RATE;
	return rate;
}

+ (NSString*)broadcastProtocol
{
	NSString* protocol = [self readStringValue:@PREF_NAME_BROADCAST_PROTOCOL];

	if ((protocol == nil) || ([protocol length] == 0))
		protocol = @DEFAULT_PROTOCOL;
	return protocol;
}

+ (NSString*)broadcastHostName
{
	NSString* hostName = [self readStringValue:@PREF_NAME_BROADCAST_HOST_NAME];

	if ((hostName == nil) || ([hostName length] == 0))
		hostName = @DEFAULT_HOST_NAME;
	return hostName;
}

+ (BOOL)broadcastShowIcon
{
	return [self readBooleanValue:@PREF_NAME_BROADCAST_SHOW_ICON];
}

+ (BOOL)willIntegrateHealthKitActivities
{
	return [self readBooleanValue:@PREF_NAME_WILL_INTEGRATE_HEALTH_KIT_ACTIVITIES];
}

+ (BOOL)hideHealthKitDuplicates
{
	return [self readBooleanValue:@PREF_NAME_HIDE_HEALTH_KIT_DUPLICATES];
}

+ (BOOL)hasShownFirstTimeUseMessage
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_FIRST_TIME_USE_MSG];
}

+ (BOOL)hasShownPullUpHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_PULL_UP_HELP];
}

+ (BOOL)hasShownPushUpHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_PUSH_UP_HELP];
}

+ (BOOL)hasShownRunningHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_RUNNING_HELP];
}

+ (BOOL)hasShownCyclingHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_CYCLING_HELP];
}

+ (BOOL)hasShownSquatHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_SQUAT_HELP];
}

+ (BOOL)hasShownStationaryBikeHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_STATIONARY_BIKE_HELP];
}

+ (BOOL)hasShownTreadmillHelp
{
	return [self readBooleanValue:@PREF_NAME_HAS_SHOWN_TREADMILL_HELP];
}

+ (BOOL)useWatchHeartRate
{
	return [self readBooleanValue:@PREF_NAME_USE_WATCH_HEART_RATE];
}

+ (Goal)workoutGoal
{
	NSInteger goal = [self readNumericValue:@PREF_NAME_WORKOUT_GOAL];
	return (Goal)goal;
}

+ (GoalType)workoutGoalType
{
	NSInteger goalType = [self readNumericValue:@PREF_NAME_WORKOUT_GOAL_TYPE];
	return (GoalType)goalType;
}

+ (time_t)workoutGoalDate
{
	NSInteger goalDate = [self readNumericValue:@PREF_NAME_WORKOUT_GOAL_DATE];
	return (time_t)goalDate;
}

+ (DayType)workoutLongRunDay
{
	NSInteger dayType = [self readNumericValue:@PREF_NAME_WORKOUT_LONG_RUN_DAY];
	return (DayType)dayType;
}

+ (BOOL)workoutsCanIncludePoolSwims
{
	return [self readBooleanValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_POOL_SWIMS];
}

+ (BOOL)workoutsCanIncludeOpenWaterSwims
{
	return [self readBooleanValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_OPEN_WATER_SWIMS];
}

+ (BOOL)workoutsCanIncludeBikeRides
{
	return [self readBooleanValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_BIKE_RIDES];
}

+ (BOOL)workoutsCanIncludeRunning
{
	return [self readBooleanValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_RUNNING];
}

+ (uint16_t)poolLength
{
	NSInteger poolLength = [self readNumericValue:@PREF_NAME_POOL_LENGTH];
	return (uint16_t)poolLength;
}

+ (UnitSystem)poolLengthUnits
{
	NSInteger poolLengthUnits = [self readNumericValue:@PREF_NAME_POOL_LENGTH_UNITS];
	return (UnitSystem)poolLengthUnits;
}

+ (time_t)lastServerSyncTime
{
	NSInteger syncTime = [self readNumericValue:@PREF_NAME_LAST_SERVER_SYNC_TIME];
	return (time_t)syncTime;
}

#pragma mark set methods

+ (void)setUuid:(NSString*)value
{
	[self writeStringValue:@PREF_NAME_UUID withValue:value];
}

+ (void)setPreferredUnitSystem:(UnitSystem)system
{
	switch (system)
	{
		case UNIT_SYSTEM_US_CUSTOMARY:
			[Preferences writeStringValue:@PREF_NAME_UNITS withValue:@PREF_NAME_US_CUSTOMARY];
			break;
		case UNIT_SYSTEM_METRIC:
			[Preferences writeStringValue:@PREF_NAME_UNITS withValue:@PREF_NAME_METRIC];
			break;
	}
}

+ (void)setAutoScaleMap:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_AUTOSCALE_MAP withValue:value];
}

+ (void)setSmoothPaths:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_SMOOTH_PATHS withValue:value];
}

+ (void)setScanForSensors:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_SCAN_FOR_SENSORS withValue:value];
}

+ (void)setBroadcastToServer:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_BROADCAST_TO_SERVER withValue:value];
}

+ (void)setBroadcastUserName:(NSString*)value
{
	[self writeStringValue:@PREF_NAME_BROADCAST_USER_NAME withValue:value];
}

+ (void)setBroadcastRate:(NSInteger)value
{
	if (value < MAX_BROADCAST_RATE)
		return;
	if (value > MIN_BROADCAST_RATE)
		return;
	[self writeIntValue:@PREF_NAME_BROADCAST_RATE withValue:value];
}

+ (void)setBroadcastProtocol:(NSString*)value
{
	[self writeStringValue:@PREF_NAME_BROADCAST_PROTOCOL withValue:value];
}

+ (void)setBroadcastHostName:(NSString*)value
{
	[self writeStringValue:@PREF_NAME_BROADCAST_HOST_NAME withValue:value];
}

+ (void)setBroadcastShowIcon:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_BROADCAST_SHOW_ICON withValue:value];
}

+ (void)setWillIntegrateHealthKitActivities:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_WILL_INTEGRATE_HEALTH_KIT_ACTIVITIES withValue:value];
}

+ (void)setHideHealthKitDuplicates:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HIDE_HEALTH_KIT_DUPLICATES withValue:value];
}

+ (void)setHashShownFirstTimeUseMessage:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_FIRST_TIME_USE_MSG withValue:value];
}

+ (void)setHasShownPullUpHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_PULL_UP_HELP withValue:value];
}

+ (void)setHasShownPushUpHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_PUSH_UP_HELP withValue:value];
}

+ (void)setHasShownRunningHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_RUNNING_HELP withValue:value];
}

+ (void)setHasShownCyclingHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_CYCLING_HELP withValue:value];
}

+ (void)setHasShownSquatHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_SQUAT_HELP withValue:value];
}

+ (void)setHasShownStationaryBikeHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_STATIONARY_BIKE_HELP withValue:value];
}

+ (void)setHasShownTreadmillHelp:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_HAS_SHOWN_TREADMILL_HELP withValue:value];
}

+ (void)setUseWatchHeartRate:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_USE_WATCH_HEART_RATE withValue:value];
}

+ (void)setWorkoutGoal:(Goal)value
{
	[self writeIntValue:@PREF_NAME_WORKOUT_GOAL withValue:(NSInteger)value];
}

+ (void)setWorkoutGoalType:(GoalType)value
{
	[self writeIntValue:@PREF_NAME_WORKOUT_GOAL_TYPE withValue:(NSInteger)value];
}

+ (void)setWorkoutGoalDate:(time_t)value
{
	[self writeIntValue:@PREF_NAME_WORKOUT_GOAL_DATE withValue:(NSInteger)value];
}

+ (void)setWorkoutLongRunDay:(DayType)value
{
	[self writeIntValue:@PREF_NAME_WORKOUT_LONG_RUN_DAY withValue:(NSInteger)value];
}

+ (void)setWorkoutsCanIncludePoolSwims:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_POOL_SWIMS withValue:value];
}

+ (void)setWorkoutsCanIncludeOpenWaterSwims:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_OPEN_WATER_SWIMS withValue:value];
}

+ (void)setWorkoutsCanIncludeBikeRides:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_BIKE_RIDES withValue:value];
}

+ (void)setWorkoutsCanIncludeRunning:(BOOL)value
{
	[self writeBoolValue:@PREF_NAME_WORKOUTS_CAN_INCLUDE_RUNNING withValue:value];
}

+ (void)setPoolLength:(uint16_t)poolLength
{
	[self writeIntValue:@PREF_NAME_POOL_LENGTH withValue:(NSInteger)poolLength];
}

+ (void)setPoolLengthUnits:(UnitSystem)poolLengthUnits
{
	[self writeIntValue:@PREF_NAME_POOL_LENGTH_UNITS withValue:(NSInteger)poolLengthUnits];
}

+ (void)setLastServerSyncTime:(time_t)value
{
	[self writeIntValue:@PREF_NAME_LAST_SERVER_SYNC_TIME withValue:(NSInteger)value];
}

#pragma mark methods for managing the list of accessories

+ (NSArray*)listPeripheralsToUse
{
	NSString* peripheralList = [self readStringValue:@PREF_NAME_ALWAYS_CONNECT];
	return [peripheralList componentsSeparatedByString:@";"];
}

+ (void)addPeripheralToUse:(NSString*)uuid
{
	if (![self shouldUsePeripheral:uuid])
	{
		NSString* peripheralList = [self readStringValue:@PREF_NAME_ALWAYS_CONNECT];

		if (peripheralList && ([peripheralList length] > 0))
		{
			NSString* newList = [peripheralList stringByAppendingFormat:@";%@", uuid];
			[self writeStringValue:@PREF_NAME_ALWAYS_CONNECT withValue:newList];
		}
		else
		{
			[self writeStringValue:@PREF_NAME_ALWAYS_CONNECT withValue:uuid];
		}
	}
}

+ (void)removePeripheralFromUseList:(NSString*)uuid
{
	NSString* peripheralList = [self readStringValue:@PREF_NAME_ALWAYS_CONNECT];
	NSRange rangeOfSubstring = [peripheralList rangeOfString:uuid];

	if (rangeOfSubstring.location != NSNotFound)
	{
		NSString* newList = [peripheralList substringToIndex:rangeOfSubstring.location];
		newList = [newList stringByReplacingOccurrencesOfString:@";;" withString:@";"];
		[self writeStringValue:@PREF_NAME_ALWAYS_CONNECT withValue:newList];
	}
}

+ (BOOL)shouldUsePeripheral:(NSString*)uuid
{
	NSString* peripheralList = [self readStringValue:@PREF_NAME_ALWAYS_CONNECT];

	if (peripheralList)
	{
		NSRange range = [peripheralList rangeOfString:uuid options:NSCaseInsensitiveSearch];
		return (range.location != NSNotFound);
	}
	return false;
}

#pragma mark import and export methods

+ (NSMutableDictionary*)exportPrefs
{
	NSMutableDictionary* prefs = [[NSMutableDictionary alloc] init];

	[prefs setObject:[NSNumber numberWithInteger:[self preferredUnitSystem]] forKey:@PREF_NAME_UNITS];
	[prefs setObject:[NSNumber numberWithBool:[self shouldScanForSensors]] forKey:@PREF_NAME_SCAN_FOR_SENSORS];
	[prefs setObject:[NSNumber numberWithBool:[self shouldBroadcastToServer]] forKey:@PREF_NAME_BROADCAST_TO_SERVER];
	NSString* temp = [self broadcastUserName];
	if (temp)
		[prefs setObject:temp forKey:@PREF_NAME_BROADCAST_USER_NAME];
	[prefs setObject:[NSNumber numberWithInteger:[self broadcastRate]] forKey:@PREF_NAME_BROADCAST_RATE];
	if (temp)
		temp = [self broadcastProtocol];
	[prefs setObject:[self broadcastProtocol] forKey:@PREF_NAME_BROADCAST_PROTOCOL];
	if (temp)
		temp = [self broadcastHostName];
	[prefs setObject:[self broadcastHostName] forKey:@PREF_NAME_BROADCAST_HOST_NAME];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownFirstTimeUseMessage]] forKey:@PREF_NAME_HAS_SHOWN_FIRST_TIME_USE_MSG];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownPullUpHelp]] forKey:@PREF_NAME_HAS_SHOWN_PULL_UP_HELP];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownPushUpHelp]] forKey:@PREF_NAME_HAS_SHOWN_PUSH_UP_HELP];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownRunningHelp]] forKey:@PREF_NAME_HAS_SHOWN_RUNNING_HELP];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownCyclingHelp]] forKey:@PREF_NAME_HAS_SHOWN_CYCLING_HELP];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownSquatHelp]] forKey:@PREF_NAME_HAS_SHOWN_SQUAT_HELP];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownStationaryBikeHelp]] forKey:@PREF_NAME_HAS_SHOWN_STATIONARY_BIKE_HELP];
	[prefs setObject:[NSNumber numberWithBool:[self hasShownTreadmillHelp]] forKey:@PREF_NAME_HAS_SHOWN_TREADMILL_HELP];
	return prefs;
}

+ (void)importPrefs:(NSDictionary*)prefs
{
	for (NSString* key in prefs)
	{
		if ([key isEqualToString:@PREF_NAME_UNITS])
		{
			long tempValue = (long)[prefs objectForKey:key];

            if (tempValue == (long)UNIT_SYSTEM_METRIC)
                [Preferences setPreferredUnitSystem:UNIT_SYSTEM_METRIC];
            else if (tempValue == (long)UNIT_SYSTEM_US_CUSTOMARY)
                [Preferences setPreferredUnitSystem:UNIT_SYSTEM_US_CUSTOMARY];
		}
		else if ([key isEqualToString:@PREF_NAME_SCAN_FOR_SENSORS])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setScanForSensors:value];
		}
		else if ([key isEqualToString:@PREF_NAME_BROADCAST_TO_SERVER])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setBroadcastToServer:value];
		}
		else if ([key isEqualToString:@PREF_NAME_BROADCAST_USER_NAME])
		{
			NSString* value = (NSString*)[prefs objectForKey:key];
			[Preferences setBroadcastUserName:value];
		}
		else if ([key isEqualToString:@PREF_NAME_BROADCAST_RATE])
		{
			NSInteger value = (NSInteger)[prefs objectForKey:key];
			[Preferences setBroadcastRate:value];
		}
		else if ([key isEqualToString:@PREF_NAME_BROADCAST_PROTOCOL])
		{
			NSString* value = (NSString*)[prefs objectForKey:key];
			[Preferences setBroadcastProtocol:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_FIRST_TIME_USE_MSG])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHashShownFirstTimeUseMessage:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_PULL_UP_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownPullUpHelp:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_PUSH_UP_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownPushUpHelp:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_RUNNING_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownRunningHelp:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_CYCLING_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownCyclingHelp:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_SQUAT_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownSquatHelp:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_STATIONARY_BIKE_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownStationaryBikeHelp:value];
		}
		else if ([key isEqualToString:@PREF_NAME_HAS_SHOWN_TREADMILL_HELP])
		{
			bool value = (bool)[prefs objectForKey:key];
			[Preferences setHasShownTreadmillHelp:value];
		}
	}
}

@end
