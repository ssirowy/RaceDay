//
//  M2XTrigger.m
//  M2XLib
//
//  Created by Luis Floreani on 12/1/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XTrigger.h"
#import "M2XDevice.h"

static NSString * const kPath = @"/triggers";

@implementation M2XTrigger

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

- (NSString *)path {
    return [NSString stringWithFormat:@"%@/triggers/%@", _device.path, [self[@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
