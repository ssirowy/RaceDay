//
//  M2XDistribution.h
//  M2XLib
//
//  Created by Luis Floreani on 12/1/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XResource.h"

@interface M2XDistribution : M2XResource

// Retrieve list of device distributions accessible by the authenticated
// API key.
//
// https://m2x.att.com/developer/documentation/v2/distribution#List-Distributions
+ (void)listWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// Create a new device distribution
//
// https://m2x.att.com/developer/documentation/v2/distribution#Create-Distribution
+ (void)createWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XDistributionCallback)completionHandler;


// Retrieve list of devices added to the specified distribution.
//
// https://m2x.att.com/developer/documentation/v2/distribution#List-Devices-from-an-existing-Distribution
- (void)devicesWithCompletionHandler:(M2XArrayCallback)completionHandler;

// Add a new device to an existing distribution
//
// Accepts a `serial` parameter, that must be a unique identifier
// within this distribution.
//
// https://m2x.att.com/developer/documentation/v2/distribution#Add-Device-to-an-existing-Distribution
- (void)addDevice:(NSString *)serial completionHandler:(M2XDeviceCallback)completionHandler;

@end
