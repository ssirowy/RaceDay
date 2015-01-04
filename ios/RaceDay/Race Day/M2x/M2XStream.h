//
//  M2XStream.h
//  M2X_iOS
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XResource.h"

@interface M2XStream : M2XResource

- (instancetype)initWithClient:(M2XClient *)client device:(M2XDevice *)device attributes:(NSDictionary *)attributes;

// Get details of a specific data Stream associated with a device
//
// https://m2x.att.com/developer/documentation/v2/device#View-Data-Stream
+ (void)fetchWithClient:(M2XClient *)client device:(M2XDevice *)device name:(NSString *)name completionHandler:(M2XStreamCallback)completionHandler;

// Retrieve list of data streams associated with a device.
//
// https://m2x.att.com/developer/documentation/v2/device#List-Data-Streams
+ (void)listWithClient:(M2XClient *)client device:(M2XDevice *)device completionHandler:(M2XArrayCallback)completionHandler;

// Update stream properties
// (if the stream does not exist it gets created).
//
// https://m2x.att.com/developer/documentation/v2/device#Create-Update-Data-Stream
- (void)updateWithParameters:(NSDictionary *)parameters completionHandler:(M2XStreamCallback)completionHandler;

// List values from the stream, sorted in reverse chronological order
// (most recent values first).
//
// https://m2x.att.com/developer/documentation/v2/device#List-Data-Stream-Values
- (void)valuesWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// Sample values from the stream, sorted in reverse chronological order
// (most recent values first).
//
// This method only works for numeric streams
//
// https://m2x.att.com/developer/documentation/v2/device#Data-Stream-Sampling
- (void)samplingWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// Return count, min, max, average and standard deviation stats for the
// values of the stream.
//
// This method only works for numeric streams
//
// https://m2x.att.com/developer/documentation/v2/device#Data-Stream-Stats
- (void)statsWithParameters:(NSDictionary *)parameters completionHandler:(M2XBaseCallback)completionHandler;

// Post multiple values to the stream
//
// The `values` parameter is an array with the following format:
//
//     @[
//       @{ @"timestamp": <Time in ISO8601>, @"value": x },
//       @{ @"timestamp": <Time in ISO8601>, @"value": y },
//       @{ ... }
//     ]
//
// https://m2x.att.com/developer/documentation/v2/device#Post-Data-Stream-Values
- (void)postValues:(NSArray *)values completionHandler:(M2XBaseCallback)completionHandler;

// Update the current value of the stream. The timestamp
// is optional. If ommited, the current server time will be used
//
// https://m2x.att.com/developer/documentation/v2/device#Update-Data-Stream-Value
- (void)updateValue:(NSNumber *)value timestamp:(NSString *)timestamp completionHandler:(M2XBaseCallback)completionHandler;

// Delete values in a stream by a date range
// The `start` and `stop` parameters should be ISO8601 timestamps
//
// https://m2x.com/developer/documentation/v2/device#Delete-Data-Stream-Values
- (void)deleteValuesFrom:(NSString *)start to:(NSString *)stop completionHandler:(M2XBaseCallback)completionHandler;


@end
