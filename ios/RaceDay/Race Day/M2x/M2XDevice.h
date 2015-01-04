//
//  M2XDevice.h
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2XResource.h"

@interface M2XDevice : M2XResource

// Search the catalog of public Devices.
//
// This allows unauthenticated users to search Devices from other users
// that have been marked as public, allowing them to read public Device
// metadata, locations, streams list, and view each Devices' stream metadata
// and its values.
//
// https://m2x.att.com/developer/documentation/v2/device#List-Search-Public-Devices-Catalog
+ (void)catalogWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// Retrieve the list of devices accessible by the authenticated API key that
// meet the search criteria.
//
// https://m2x.att.com/developer/documentation/v2/device#List-Search-Devices
+ (void)listWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// List Device Groups
// Retrieve the list of device groups for the authenticated user.
//
// https://m2x.att.com/developer/documentation/v2/device#List-Device-Groups
+ (void)groupsWithClient:(M2XClient *)client completionHandler:(M2XBaseCallback)completionHandler;

// Create a new device
//
// https://m2x.att.com/developer/documentation/v2/device#Create-Device
+ (void)createWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XDeviceCallback)completionHandler;

// View Request Log
// Retrieve list of HTTP requests received lately by the specified device
// (up to 100 entries).
//
// https://m2x.att.com/developer/documentation/v2/device#View-Request-Log
- (void)logWithCompletionHandler:(M2XBaseCallback)completionHandler;

// Get location details of an existing Device.
//
// Note that this method can return an empty value (response status
// of 204) if the device has no location defined.
//
// https://m2x.att.com/developer/documentation/v2/device#Read-Device-Location
- (void)locationWithCompletionHandler:(M2XBaseCallback)completionHandler;

// Update the current location of the specified device.
//
// https://m2x.att.com/developer/documentation/v2/device#Update-Device-Location
- (void)updateLocation:(NSDictionary *)parameters completionHandler:(M2XDeviceCallback)completionHandler;

// Post Device Updates (Multiple Values to Multiple Streams)
//
// This method allows posting multiple values to multiple streams
// belonging to a device and optionally, the device location.
//
// All the streams should be created before posting values using this method.
//
// The `values` parameter contains a dictionary with one attribute per each stream to be updated.
// The value of each one of these attributes is an array of timestamped values.
//
//      @{
//         @"temperature": [
//                        @{ @"timestamp": <Time in ISO8601>, @"value": x },
//                        @{ @"timestamp": <Time in ISO8601>, @"value": y },
//                      ],
//         @"humidity":    [
//                        @{ @"timestamp": <Time in ISO8601>, @"value": x },
//                        @{ @"timestamp": <Time in ISO8601>, @"value": y },
//                      ]
//
//      }
//
// https://staging.m2x.sl.attcompute.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams-
- (void)postUpdates:(NSDictionary *)values completionHandler:(M2XBaseCallback)completionHandler;

// Retrieve list of data streams associated with the device.
//
// https://m2x.att.com/developer/documentation/v2/device#List-Data-Streams
- (void)streamsWithCompletionHandler:(M2XArrayCallback)completionHandler;

// Get details of a specific data Stream associated with the device
//
// https://m2x.att.com/developer/documentation/v2/device#View-Data-Stream
- (void)streamsWithName:(NSString *)name completionHandler:(M2XStreamCallback)completionHandler;

// Update a data stream associated with the Device
// (if a stream with this name does not exist it gets created).
//
// https://m2x.att.com/developer/documentation/v2/device#Create-Update-Data-Stream
- (void)updateStreamWithName:(NSString *)name parameters:(NSDictionary *)parameters completionHandler:(M2XStreamCallback)completionHandler;

// Retrieve list of triggers associated with the device.
//
- (void)triggersWithCompletionHandler:(M2XArrayCallback)completionHandler;

// Create a new trigger
//
- (void)createTrigger:(NSDictionary *)parameters withCompletionHandler:(M2XTriggerCallback)completionHandler;

@end
