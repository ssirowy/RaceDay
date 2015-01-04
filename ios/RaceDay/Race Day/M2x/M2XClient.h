//
//  M2XClient.h
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2XResponse.h"

@class M2XDevice;
@class M2XTrigger;
@class M2XStream;
@class M2XKey;
@class M2XResource;
@class M2XDistribution;

typedef void (^M2XBaseCallback)(M2XResponse *response);
typedef void (^M2XResourceCallback)(M2XResource *resource, M2XResponse *response);
typedef void (^M2XDeviceCallback)(M2XDevice *device, M2XResponse *response);
typedef void (^M2XTriggerCallback)(M2XTrigger *trigger, M2XResponse *response);
typedef void (^M2XStreamCallback)(M2XStream *stream, M2XResponse *response);
typedef void (^M2XKeyCallback)(M2XKey *key, M2XResponse *response);
typedef void (^M2XDistributionCallback)(M2XDistribution *distribution, M2XResponse *response);
typedef void (^M2XArrayCallback)(NSArray *objects, M2XResponse *response);

typedef void (^M2XResponseCallback)(NSData *data, NSURLResponse *response, NSError *error);

@protocol M2XClientDelegate <NSObject>

// Gives the opportunity to handle the response, which is now your responsability to create the proper M2XResponse object can call the completionHandler
- (void)handleResponseWithData:(NSData *)data request:(NSURLRequest *)request response:(NSHTTPURLResponse *)response error:(NSError *)error completionHandler:(M2XBaseCallback)completionHandler;

@optional

// Allow to decide on run time if the delegate can handle requests
- (BOOL)canHandleRequest:(NSURLRequest *)request;

// Gives the opportunity to handle the request, which is now your responsability to create the proper data, response and error
- (void)handleRequest:(NSURLRequest *)request completionHandler:(M2XResponseCallback)completionHandler;

@end

// Interface for connecting with M2X API service.
//
// This class provides convenience methods to access M2X most common resources.
// It can also be used to access any endpoint directly like this:
//
//     M2XClient *m2x = [[M2XClient alloc] initWithApiKey:"<YOUR-API-KEY>"];
//     [m2x getWithPath:@"/some_path" parameters:...];
//
@interface M2XClient : NSObject

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *apiBaseUrl;
@property (nonatomic, copy) NSString *apiVersion;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, weak) id<M2XClientDelegate> delegate;

+ (NSString *)version;

- (instancetype)initWithApiKey:(NSString *)apiKey;

// Returns the status of the M2X system.
//
// The response to this endpoint is an object in which each of its attributes
// represents an M2X subsystem and its current status.
- (void)statusWithCompletionHandler:(M2XBaseCallback)completionHandler;

// Retrieve the list of devices accessible by the authenticated API key that
// meet the search criteria.
//
// See M2XDevice.listWithClient:parameters:completionHandler: for more details
- (void)devicesWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// Obtain a Device from M2X
//
// This method instantiates an instance of Device and calls `M2XDevice.viewWithCompletionHandler:`
// method, returning the device instance with all its attributes initialized
- (void)deviceWithId:(NSString *)identifier completionHandler:(M2XDeviceCallback)completionHandler;

// Creates a new device on M2X with the specified parameters
- (void)createDeviceWithParameters:(NSDictionary *)parameters completionHandler:(M2XDeviceCallback)completionHandler;

// Search the catalog of public Devices.
//
// This allows unauthenticated users to search Devices from other users that
// have been marked as public, allowing them to read public Device metadata,
// locations, streams list, and view each Devices' stream metadata and its
// values.
//
// See M2XDevice.catalogWithClient:parameters:completionHandler: for more details
- (void)deviceCatalogWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;


// Retrieve list of keys associated with the user account.
//
// See M2XKey.listWithClient:parameters:completionHandler: for more details
- (void)keysWithCompletionHandler:(M2XArrayCallback)completionHandler;

// Obtain an API Key from M2X
//
// This method instantiates an instance of Key and calls
// `M2XKey.viewWithCompletionHandler:` method, returning the key instance with all
// its attributes initialized
- (void)keyWithKey:(NSString *)key completionHandler:(M2XKeyCallback)completionHandler;

// Create a new API Key
//
// Note that, according to the parameters sent, you can create a
// Master API Key or a Device/Stream API Key.
- (void)createKeyWithParameters:(NSDictionary *)parameters completionHandler:(M2XKeyCallback)completionHandler;

// Retrieve list of device distributions accessible by the authenticated
// API key.
//
// See M2XDistribution.listWithClient:parameters:completionHandler: for more details
- (void)distributionsWithCompletionHandler:(M2XArrayCallback)completionHandler;

// Obtain a Distribution from M2X
//
// This method instantiates an instance of Distribution and calls
// `M2XDistribution.viewWithCompletionHandler:` method, returning the device instance with all
// its attributes initialized
- (void)distributionWithId:(NSString *)identifier completionHandler:(M2XDistributionCallback)completionHandler;

// Creates a new device distribution on M2X with the specified parameters
- (void)createDistributionWithParameters:(NSDictionary *)parameters completionHandler:(M2XDistributionCallback)completionHandler;

- (NSString *)userAgent;
- (NSString *)apiUrl;

@end
