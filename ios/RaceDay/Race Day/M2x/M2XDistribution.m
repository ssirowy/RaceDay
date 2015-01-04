//
//  M2XDistribution.m
//  M2XLib
//
//  Created by Luis Floreani on 12/1/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XDistribution.h"
#import "M2XDevice.h"

static NSString * const kPath = @"/distributions";

@implementation M2XDistribution

+ (void)listWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [client getWithPath:kPath parameters:parameters completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"distributions"]) {
            M2XDistribution *dist = [[M2XDistribution alloc] initWithClient:client attributes:dict];
            [array addObject:dist];
        }
        
        completionHandler(array, response);
    }];
}

+ (void)createWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XDistributionCallback)completionHandler {
    [client postWithPath:kPath parameters:parameters completionHandler:^(M2XResponse *response) {
        M2XDistribution *dist = [[M2XDistribution alloc] initWithClient:client attributes:response.json];
        completionHandler(dist, response);
    }];
}

- (void)devicesWithCompletionHandler:(M2XArrayCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/devices", [self path]] parameters:nil completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"devices"]) {
            M2XDevice *dev = [[M2XDevice alloc] initWithClient:self.client attributes:dict];
            [array addObject:dev];
        }
        
        completionHandler(array, response);
    }];
}

- (void)addDevice:(NSString *)serial completionHandler:(M2XDeviceCallback)completionHandler {
    [self.client postWithPath:[NSString stringWithFormat:@"%@/devices", [self path]] parameters:@{@"serial": serial} completionHandler:^(M2XResponse *response) {
        M2XDevice *device = [[M2XDevice alloc] initWithClient:self.client attributes:response.json];
        completionHandler(device, response);
    }];
}

- (NSString *)path {
    return [NSString stringWithFormat:@"%@/%@", kPath, [self[@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
