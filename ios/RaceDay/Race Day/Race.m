//
//  Race.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "Race.h"

@implementation Race

- (id)initWithFeature:(AGSGraphic*)race
{
    self = [super init];
    if (self) {
        _graphic = race;
    }
    
    return self;
}

- (NSString*)raceId
{
    return nil;
}

- (NSString*)title
{
    return nil;
}

- (NSDate*)startTime
{
    return nil;
}

- (NSDate*)endDate
{
    return nil;
}

@end
