//
//  SpeedDataSource.m
//  RaceDay
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "SpeedDataSource.h"

@interface SpeedDataSource ()

@property (nonatomic) NSUInteger xValue;
@property (nonatomic) float constantVal;

@end

@implementation SpeedDataSource

- (id)initWithSimulateSpeed:(RaceSimulatedSpeed)speed
{
    self = [super init];
    if (self) {
        _xValue = 0;
        
        switch (speed) {
            case RaceSimulatedSpeedFast:
                _constantVal = 5.5394;
                break;
            case RaceSimulatedSpeedMedium:
                _constantVal = 4.5;
                break;
            default:
                _constantVal = 3.675;
                break;
        }
    }
    
    return self;
}

#define kAConstant 0.0003
#define kBConstant -0.0175
#define kCConstant 0.346

- (NSNumber*)nextSimulatedSpeed
{
    float val =  ((self.xValue*self.xValue*self.xValue*kAConstant) +
                  (self.xValue*self.xValue*kBConstant) +
                  (self.xValue*kCConstant) +
                  self.constantVal);
    
     float low = -0.15;
     float high = 0.15;
     float diff = high - low;
     float offset = (((float) rand() / RAND_MAX) * diff) + low;
    val += offset;
    
    _xValue += 1;
    return [NSNumber numberWithFloat:val];
}

@end
