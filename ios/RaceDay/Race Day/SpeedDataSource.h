//
//  SpeedDataSource.h
//  RaceDay
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Race.h"

@interface SpeedDataSource : NSObject

- (id)initWithSimulateSpeed:(RaceSimulatedSpeed)speed;

- (NSNumber*)nextSimulatedSpeed;

@end
