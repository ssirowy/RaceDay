//
//  RaceMapView.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "RaceMapView.h"

static RaceMapView* sharedMapView;

@implementation RaceMapView

+ (RaceMapView*)sharedMapView
{
    if (!sharedMapView) {
        sharedMapView = [[RaceMapView alloc] init];
    }
    
    return sharedMapView;
}

@end
