//
//  M2XStream.m
//  M2X_iOS
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XStream.h"
#import "M2XDevice.h"
#import "NSDate+M2X.h"

@interface M2XStream()
@property (nonatomic, strong) M2XDevice *device;
@end

@implementation M2XStream

+ (void)fetchWithClient:(M2XClient *)client device:(M2XDevice *)device name:(NSString *)name completionHandler:(M2XStreamCallback)completionHandler {
    [client getWithPath:[NSString stringWithFormat:@"%@/streams/%@", device.path, name] parameters:nil completionHandler:^(M2XResponse *response) {
        M2XStream *stream = [[M2XStream alloc] initWithClient:client device:device attributes:response.json];
        completionHandler(stream, response);
    }];    
}

+ (void)listWithClient:(M2XClient *)client device:(M2XDevice *)device completionHandler:(M2XArrayCallback)completionHandler {
    [client getWithPath:[NSString stringWithFormat:@"%@/streams", device.path] parameters:nil completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"streams"]) {
            M2XStream *stream = [[M2XStream alloc] initWithClient:client device:device attributes:dict];
            [array addObject:stream];
        }
        
        completionHandler(array, response);
    }];
}

- (instancetype)initWithClient:(M2XClient *)client device:(M2XDevice *)device attributes:(NSDictionary *)attributes {
    self = [super initWithClient:client attributes:attributes];
    if (self) {
        _device = device;
    }
    
    return self;
}

- (instancetype)initWithClient:(M2XClient *)client attributes:(NSDictionary *)attributes {
    @throw [NSException exceptionWithName:@"InvalidInitializer" reason:@"Can't use the default initializer" userInfo:nil];
}

- (void)updateWithParameters:(NSDictionary *)parameters completionHandler:(M2XStreamCallback)completionHandler {
    [self.client putWithPath:[self path] parameters:parameters completionHandler:^(M2XResponse *response) {
        self.attributes = response.json;
        completionHandler(self, response);
    }];
}

- (void)valuesWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/values", [self path]] parameters:parameters completionHandler:^(M2XResponse *response) {
        completionHandler(response.json[@"values"], response);
    }];
}

- (void)samplingWithParameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/sampling", [self path]] parameters:parameters completionHandler:^(M2XResponse *response) {
        completionHandler(response.json[@"values"], response);
    }];
}

- (void)statsWithParameters:(NSDictionary *)parameters completionHandler:(M2XBaseCallback)completionHandler {
    [self.client getWithPath:[NSString stringWithFormat:@"%@/stats", [self path]] parameters:parameters completionHandler:^(M2XResponse *response) {
        completionHandler(response);
    }];
}

- (void)updateValue:(NSNumber *)value timestamp:(NSString *)timestamp completionHandler:(M2XBaseCallback)completionHandler {
    NSDictionary *params;
    if (!timestamp) {
        params = @{@"value": value};
    } else {
        params = @{@"value": value, @"timestamp": timestamp};
    }
    
    [self.client putWithPath:[NSString stringWithFormat:@"%@/value", [self path]] parameters:params completionHandler:completionHandler];
}

- (void)postValues:(NSArray *)values completionHandler:(M2XBaseCallback)completionHandler {
    [self.client postWithPath:[NSString stringWithFormat:@"%@/values", [self path]] parameters:@{@"values": values} completionHandler:completionHandler];
}

- (void)deleteValuesFrom:(NSString *)start to:(NSString *)stop completionHandler:(M2XBaseCallback)completionHandler {
    NSDictionary *params = @{@"from": start, @"end": stop};
    [self.client deleteWithPath:[NSString stringWithFormat:@"%@/values", [self path]] parameters:params completionHandler:completionHandler];
}

- (NSString *)path {
    return [NSString stringWithFormat:@"%@/streams/%@", _device.path, [self[@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
