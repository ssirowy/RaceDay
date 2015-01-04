//
//  Race.h
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRaceStartedNotification @"kRaceStartedNotification"
#define kRaceEndedNotification @"kRaceEndedNotification"

@class AGSGraphic;
@class AGSGeometry;
@class AGSPoint;

typedef enum {
    RaceSimulatedSpeedSlow,
    RaceSimulatedSpeedMedium,
    RaceSimulatedSpeedFast
} RaceSimulatedSpeed;

typedef enum {
    RaceStateUnknown = 0,
    RaceStateNotStarted,
    RaceStateAtStart,
    RaceStateLeftStart,
    RaceStateMiddleOfRace,
    RaceStateAtFinish,
    RaceStateFinishedRace
} RaceState;

@interface Race : NSObject

@property (nonatomic, strong, readonly) AGSGraphic* graphic;

@property (nonatomic, strong, readonly) NSNumber* raceID;
@property (nonatomic, strong, readonly) NSString* title;
@property (nonatomic, strong, readonly) NSDate*   startDate;
@property (nonatomic, strong, readonly) NSDate*   endDate;

@property (nonatomic, strong) AGSGeometry* startRaceGeofence;
@property (nonatomic, strong) AGSGeometry* endRaceGeofence;

// miles
@property (nonatomic, assign) double totalDistance;

@property (nonatomic, assign) RaceState raceState;

- (id)initWithFeature:(AGSGraphic*)race;

- (AGSPoint*)startPoint;
- (AGSPoint*)endPoint;

- (void)startRaceSimulatedSpeed:(RaceSimulatedSpeed)speed;

// ONly make sense when race is being run
- (double)distanceCovered;
- (double)percentageComplete;
- (AGSPoint*)currentLocation;

@end
