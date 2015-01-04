//
//  M2XDevice.m
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XDevice.h"
#import "M2XStream.h"
#import "M2XTrigger.h"

static NSString * const kPath = @"/devices";

@implementation M2XDevice

+ (void)listWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [client getWithPath:kPath parameters:parameters completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"devices"]) {
            M2XDevice *device = [[M2XDevice alloc] initWithClient:client attributes:dict];
            [array addObject:device];
        }
        
        completionHandler(array, response);
    }];
}

+ (void)groupsWithClient:(M2XClient *)client completionHandler:(M2XBaseCallback)completionHandler {
    [client getWithPath:[NSString stringWithFormat:@"%@/groups", kPath] parameters:nil completionHandler:completionHandler];
}

+ (void)catalogWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [client getWithPath:[NSString stringWithFormat:@"%@/catalog", kPath] parameters:parameters completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"devices"]) {
            M2XDevice *device = [[M2XDevice alloc] initWithClient:client attributes:dict];
            [array addObject:device];
        }
        
        completionHandler(array, response);
    }];
}

+ (void)createWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XDeviceCallback)completionHandler {
    [client postWithPath:kPath parameters:parameters completionHandler:^(M2XResponse *response) {
        M2XDevice *device = [[M2XDevice alloc] initWithClient:client attributes:response.json];
        completionHandler(device, response);
    }];
}

- (void)logWithCompletionHandler:(M2XBaseCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/log", kPath] parameters:nil completionHandler:completionHandler];
}

- (void)streamsWithCompletionHandler:(M2XArrayCallback)completionHandler {
    [M2XStream listWithClient:self.client device:self completionHandler:completionHandler];
}

- (void)streamsWithName:(NSString *)name completionHandler:(M2XStreamCallback)completionHandler {
    [M2XStream fetchWithClient:self.client device:self name:name completionHandler:completionHandler];
}

- (void)updateStreamWithName:(NSString *)name parameters:(NSDictionary *)parameters completionHandler:(M2XStreamCallback)completionHandler {
    M2XStream *stream = [[M2XStream alloc] initWithClient:self.client device:self attributes:@{@"name": name}];
    [stream updateWithParameters:parameters completionHandler:completionHandler];
}

- (void)locationWithCompletionHandler:(M2XBaseCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/location", [self path]] parameters:nil completionHandler:^(M2XResponse *response) {
        completionHandler(response);
    }];
}

- (void)updateLocation:(NSDictionary *)parameters completionHandler:(M2XDeviceCallback)completionHandler {
    [self.client putWithPath:[NSString stringWithFormat:@"%@/location", [self path]] parameters:parameters completionHandler:^(M2XResponse *response) {
        completionHandler(self, response);
    }];
}

- (void)postUpdates:(NSDictionary *)values completionHandler:(M2XBaseCallback)completionHandler {
    [self.client postWithPath:[NSString stringWithFormat:@"%@/updates", [self path]] parameters:values completionHandler:completionHandler];
}

- (void)triggersWithCompletionHandler:(M2XArrayCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/triggers", [self path]] parameters:nil completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"triggers"]) {
            M2XTrigger *trigger = [[M2XTrigger alloc] initWithClient:self.client device:self attributes:dict];
            [array addObject:trigger];
        }
        
        completionHandler(array, response);
    }];
}

- (void)createTrigger:(NSDictionary *)parameters withCompletionHandler:(M2XTriggerCallback)completionHandler {
    [self.client postWithPath:[NSString stringWithFormat:@"%@/triggers", [self path]] parameters:parameters completionHandler:^(M2XResponse *response) {
        M2XTrigger *trigger = [[M2XTrigger alloc] initWithClient:self.client device:self attributes:response.json];
        completionHandler(trigger, response);
    }];
}

- (NSString *)path {
    return [NSString stringWithFormat:@"%@/%@", kPath, [self[@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
