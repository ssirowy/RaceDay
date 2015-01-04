//
//  M2XTrigger.h
//  M2XLib
//
//  Created by Luis Floreani on 12/1/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XResource.h"

@interface M2XTrigger : M2XResource

@property (readonly) M2XDevice *device;

- (instancetype)initWithClient:(M2XClient *)client device:(M2XDevice *)device attributes:(NSDictionary *)attributes;

@end
