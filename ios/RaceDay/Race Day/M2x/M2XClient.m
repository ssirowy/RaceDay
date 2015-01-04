//
//  M2XClient.m
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XClient.h"
#import "M2XDevice.h"
#import "M2XStream.h"
#import "M2XDistribution.h"
#import "M2XKey.h"
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>

static NSString * const kDefaultApiBase = @"https://api-m2x.att.com";
static NSString * const kDefaultApiVersion = @"v2";
static NSString * const kLibVersion = @"2.0.2";

@implementation M2XClient

- (instancetype)initWithApiKey:(NSString *)apiKey {
    self = [super init];
    
    if (self) {
        _apiKey = apiKey;
        _apiBaseUrl = kDefaultApiBase;
        _apiVersion = kDefaultApiVersion;
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return self;
}

+ (NSString *)version {
    return kLibVersion;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"InvalidInitializer" reason:@"Can't use the default initializer" userInfo:nil];
}

- (void)statusWithCompletionHandler:(M2XBaseCallback)completionHandler {
    [self getWithPath:@"/status" parameters:nil completionHandler:completionHandler];
}

- (void)devicesWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [M2XDevice listWithClient:self parameters:parameters completionHandler:completionHandler];
}

- (void)deviceWithId:(NSString *)identifier completionHandler:(M2XDeviceCallback)completionHandler {
    M2XDevice *device = [[M2XDevice alloc] initWithClient:self attributes:@{@"id": identifier}];
    [device viewWithCompletionHandler:^(M2XResource *resource, M2XResponse *response) {
        completionHandler((M2XDevice *)resource, response);
    }];
}

- (void)createDeviceWithParameters:(NSDictionary *)parameters completionHandler:(M2XDeviceCallback)completionHandler {
    [M2XDevice createWithClient:self parameters:parameters completionHandler:completionHandler];
}

- (void)deviceCatalogWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [M2XDevice catalogWithClient:self parameters:parameters completionHandler:completionHandler];
}

- (void)keysWithCompletionHandler:(M2XArrayCallback)completionHandler {
    [M2XKey listWithClient:self parameters:nil completionHandler:completionHandler];
}

- (void)keyWithKey:(NSString *)key completionHandler:(M2XKeyCallback)completionHandler {
    M2XKey *keyObj = [[M2XKey alloc] initWithClient:self attributes:@{@"key": key}];
    [keyObj viewWithCompletionHandler:^(M2XResource *resource, M2XResponse *response) {
        completionHandler((M2XKey *)resource, response);
    }];
}

- (void)createKeyWithParameters:(NSDictionary *)parameters completionHandler:(M2XKeyCallback)completionHandler {
    [M2XKey createWithClient:self parameters:parameters completionHandler:completionHandler];
}

- (void)distributionsWithCompletionHandler:(M2XArrayCallback)completionHandler {
    [M2XDistribution listWithClient:self parameters:nil completionHandler:completionHandler];
}

- (void)distributionWithId:(NSString *)identifier completionHandler:(M2XDistributionCallback)completionHandler {
    M2XDistribution *dist = [[M2XDistribution alloc] initWithClient:self attributes:@{@"id": identifier}];
    [dist viewWithCompletionHandler:^(M2XResource *resource, M2XResponse *response) {
        completionHandler((M2XDistribution *)resource, response);
    }];
}

- (void)createDistributionWithParameters:(NSDictionary *)parameters completionHandler:(M2XDistributionCallback)completionHandler {
    [M2XDistribution createWithClient:self parameters:parameters completionHandler:completionHandler];
}

- (NSString *)apiUrl {
    return [NSString stringWithFormat:@"%@/%@", _apiBaseUrl, _apiVersion];
}

- (NSString *)userAgent {
    return [NSString stringWithFormat:@"M2X-iOS/%@ (%@-%@)", kLibVersion, [self platform], [[UIDevice currentDevice] systemVersion]];
}

-(NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

@end
