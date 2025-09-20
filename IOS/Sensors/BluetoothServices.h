// Created by Michael Simms on 3/3/13.
// Copyright (c) 2013 Michael J. Simms. All rights reserved.

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#ifndef __BLUETOOTH_SERVICES__
#define __BLUETOOTH_SERVICES__

typedef enum BluetoothServiceId
{
    BT_SERVICE_GENERIC_ACCESS =                0x1800,
    BT_SERVICE_GENERIC_ATTRIBUTE =             0x1801,
    BT_SERVICE_IMMEDIATE_ALERT =               0x1802,
    BT_SERVICE_LINK_LOSS =                     0x1803,
    BT_SERVICE_TX_POWER =                      0x1804,
    BT_SERVICE_CURRENT_TIME =                  0x1805,
    BT_SERVICE_REFERENCE_TIME_UPDATE =         0x1806,
    BT_SERVICE_NEXT_DST_CHANGE =               0x1807,
    BT_SERVICE_GLUCOSE =                       0x1808,
    BT_SERVICE_HEALTH_THERMOMETER =            0x1809,
    BT_SERVICE_DEVICE_INFORMATION =            0x180A,
    BT_SERVICE_ALERT_NOTIFICATION =            0x1811,
    BT_SERVICE_HUMAN_INTERFACE_DEVICE =        0x1812,
    BT_SERVICE_SCAN_PARAMETERS =               0x1813,
    BT_SERVICE_RUNNING_SPEED_AND_CADENCE =     0x1814,
    BT_SERVICE_AUTOMATION_IO =                 0x1815,
    BT_SERVICE_CYCLING_SPEED_AND_CADENCE =     0x1816,
    BT_SERVICE_CYCLING_POWER =                 0x1818,
    BT_SERVICE_LOCATION_AND_NAVIGATION =       0x1819,
    BT_SERVICE_ENVIRONMENTAL_SENSING =         0x181A,
    BT_SERVICE_BODY_COMPOSITION =              0x181B,
    BT_SERVICE_USER_DATA =                     0x181C,
    BT_SERVICE_WEIGHT_SCALE =                  0x181D,
    BT_SERVICE_BOND_MANAGEMENT =               0x181E,
    BT_SERVICE_CONTINUOUS_GLUCOSE_MONITORING = 0x181F,
    BT_SERVICE_INTERNET_PROTOCOL_SUPPORT =     0x1820,
    BT_SERVICE_INDOOR_POSITIONING =            0x1821,
    BT_SERVICE_PULSE_OXIMETER =                0x1822,
    BT_SERVICE_HTTP_PROXY =                    0x1823,
    BT_SERVICE_OBJECT_TRANSFER =               0x1825,
    BT_SERVICE_FITNESS_MACHINE =               0x1826,
    BT_SERVICE_MESH_PROVISIONING =             0x1827,
    BT_SERVICE_MESH_PROXY =                    0x1828,
    BT_SERVICE_RECONNECTION_CONFIGURATION =    0x1829,
    BT_SERVICE_INSULING_DELIVERY =             0x183A,
    BT_SERVICE_PHYSICAL_ACTIVITY_MONITOR =     0x183E, // Physical Activity Monitor
    BT_SERVICE_WEIGHT =                        0x1901
} BluetoothServiceId;

#define CUSTOM_BT_SERVICE_FLY6_LIGHT "f000dd03-0451-4000-b000-000000000000" // Fly6 Light
#define CUSTOM_BT_SERVICE_KTV_LIGHT "29580001-d281-83bd-bc46-ad9b5bb78380" // Lezyne KTV Light
#define CUSTOM_BT_SERVICE_VARIA_RADAR "6a4e3200-667b-11e3-949a-0800200c9a66" // Garmin Varia

#endif
