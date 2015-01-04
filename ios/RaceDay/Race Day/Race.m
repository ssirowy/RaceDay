//
//  Race.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "Race.h"
#import "RaceMapView.h"
#import <ArcGIS/ArcGIS.h>
#import "M2X.h"
#import "User.h"
#import "SpeedDataSource.h"

#define kFeetPerMeter 3.28084
#define kFeetPerMile  5280

#define kM2X_API_KEY @"f778c23e3d8e5dec33674dd2fa21c5b1"
#define kM2X_DEVICE_ID  @"22e4f54c8e379e17f89e7adc2ecebf9e"

@interface Race()

@property (nonatomic, strong) AGSPolyline* raceLine;

@property (nonatomic, strong) AGSMutablePolyline* myProgress;

@property (nonatomic) double distanceInMiles;

@property (nonatomic, strong) M2XClient* m2xClient;
@property (nonatomic, strong) M2XDevice* device;
@property (nonatomic, strong) M2XStream* stream;

@property (nonatomic, assign) BOOL racing;

@property (nonatomic, strong) SpeedDataSource* speedDataSource;

@end

@implementation Race

- (id)initWithFeature:(AGSGraphic*)race
{
    self = [super init];
    if (self) {
        _graphic = race;
        
        NSDictionary* allAttributes = [race allAttributes];
        _raceID    = [allAttributes objectForKey:@"OBJECTID"];
        _title     = [allAttributes objectForKey:@"title"];
        
        double endDateVal = [[allAttributes objectForKey:@"end_time"] doubleValue] /1000;
        _endDate   = [NSDate dateWithTimeIntervalSince1970:endDateVal];
        
        
        double startDateVal = [[allAttributes objectForKey:@"start_time"] doubleValue] /1000;
        _startDate = [NSDate dateWithTimeIntervalSince1970:startDateVal];
        
        AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
        double lengthInMeters = [ge lengthOfGeometry:race.geometry];
        _totalDistance = (lengthInMeters * kFeetPerMeter)/kFeetPerMile;
        
        _raceLine = (AGSPolyline*)race.geometry;
        
        _dataPoints = [NSMutableArray array];
    }
    
    return self;
}

#define kBufferFactor 50
- (AGSGeometry*)startRaceGeofence
{
    if (_startRaceGeofence == nil) {
        AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
        AGSSpatialReference* sr = [AGSSpatialReference webMercatorSpatialReference];
        
        double distance = [sr convertValue:kBufferFactor fromUnit:AGSSRUnitMeter];
        
        AGSGeometry* projectGeometry = [ge projectGeometry:self.startPoint toSpatialReference:sr];
        _startRaceGeofence = [ge bufferGeometry:projectGeometry byDistance:distance];
    }
    
    return _startRaceGeofence;
}

- (AGSGeometry*)endRaceGeofence
{
    if (_endRaceGeofence == nil) {
        AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
        AGSSpatialReference* sr = [AGSSpatialReference webMercatorSpatialReference];
        
        double distance = [sr convertValue:kBufferFactor fromUnit:AGSSRUnitMeter];
        
        AGSGeometry* projectGeometry = [ge projectGeometry:self.endPoint toSpatialReference:sr];
        _endRaceGeofence = [ge bufferGeometry:projectGeometry byDistance:distance];
    }
    
    return _endRaceGeofence;
}

- (AGSPoint*)startPoint
{
    return [self.raceLine pointOnPath:0 atIndex:0];
}

- (AGSPoint*)endPoint
{
    return [self.raceLine pointOnPath:0 atIndex:(self.raceLine.numPoints - 1)];
}


#define kFast 90
#define kMedium (kFast / 2)
#define kSlow   (kMedium / 2)
#define kLocationPath @"location"

- (void)startRaceSimulatedSpeed:(RaceSimulatedSpeed)speed
{
    AGSGeometryEngine* engine = [AGSGeometryEngine defaultGeometryEngine];
    
    double maxLength;
    switch (speed) {
        case RaceSimulatedSpeedFast:
            maxLength = kFast;
            break;
        case RaceSimulatedSpeedMedium:
            maxLength = kMedium;
            break;
        case RaceSimulatedSpeedSlow:
            maxLength = kSlow;
            break;
        default:
            break;
    }
    
    _speedDataSource = [[SpeedDataSource alloc] initWithSimulateSpeed:speed];
    
    AGSPolyline* densifiedLine = (AGSPolyline*)[engine densifyGeometry:self.raceLine withMaxSegmentLength:maxLength];
    densifiedLine = (AGSPolyline*)[engine projectGeometry:densifiedLine toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    AGSSimulatedLocationDisplayDataSource* dataSource = [[AGSSimulatedLocationDisplayDataSource alloc] init];
    [dataSource setLocationsFromPolyline:densifiedLine];
    
    AGSLocationDisplay* display = [[RaceMapView sharedMapView] locationDisplay];
    display.dataSource = dataSource;
    [display startDataSource];
    
    [display addObserver:self forKeyPath:kLocationPath options:0 context:nil];
    
    _racing = YES;
}

- (void)endRace
{
    AGSLocationDisplay* display = [[RaceMapView sharedMapView] locationDisplay];
    [display removeObserver:self forKeyPath:kLocationPath];
    self.raceState = RaceStateNotStarted;
    [display stopDataSource];
    
    self.myProgress = nil;
    
    _racing = NO;
}

#pragma mark -
#pragma mark Race State
- (void)calculateRaceState
{
    AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSLocationDisplay* gps = [[RaceMapView sharedMapView] locationDisplay];
    AGSPoint* location = (AGSPoint*)[ge projectGeometry:gps.location.point
                                     toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    
    AGSPoint* intersectionP1 = (AGSPoint*)[ge intersectionOfGeometry:self.startRaceGeofence andGeometry:location];
    AGSPoint* intersectionP2 = (AGSPoint*)[ge intersectionOfGeometry:self.endRaceGeofence andGeometry:location];
    
    BOOL start = !(isnan(intersectionP1.x) && isnan(intersectionP1.y));
    BOOL finish = !(isnan(intersectionP2.x) && isnan(intersectionP2.y));
    
    // Actions
    switch (self.raceState) {
        case RaceStateUnknown:
            break;
        case RaceStateNotStarted:
            break;
        case RaceStateAtStart:
            break;
        case RaceStateLeftStart:
            [self startRaceInternal];
            break;
        case RaceStateMiddleOfRace:
            [self updateAndPostProgress];
            break;
        case RaceStateAtFinish:
            [[NSNotificationCenter defaultCenter] postNotificationName:kRaceEndedNotification object:self];
            [self endRace];
            break;
        case RaceStateFinishedRace:
            break;
        default:
            break;
    }
    
    // Transitions
    switch (self.raceState) {
        case RaceStateUnknown:
            if (start) {
                self.raceState = RaceStateAtStart;
            }
            break;
        case RaceStateAtStart:
            if (!start) {
                self.raceState = RaceStateLeftStart;
            }
            break;
        case RaceStateLeftStart:
            self.raceState = RaceStateMiddleOfRace;
            break;
        case RaceStateMiddleOfRace:
            if (finish) {
                self.raceState = RaceStateAtFinish;
            }
            break;
        case RaceStateAtFinish:
            self.raceState = RaceStateFinishedRace;
            break;
        default:
            break;
    }
    
    if (self.raceState != RaceStateMiddleOfRace) {
        NSLog(@"%@", [self stringFromState:self.raceState]);
    }
}

- (void)startRaceInternal
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRaceStartedNotification object:self];
    
    _myProgress = [[AGSMutablePolyline alloc] init];
    [_myProgress addPathToPolyline];
    
    
    _m2xClient = [[M2XClient alloc] initWithApiKey:kM2X_API_KEY];
    _device = [[M2XDevice alloc] initWithClient:self.m2xClient
                                     attributes:@{@"id": kM2X_DEVICE_ID}
               ];
    
    
    int raceId = (int)[self.raceID integerValue];
    NSString* email = [[User storedUser] email].length ? [[User storedUser] email] : @"danielgmail";
    
    NSString* streamName = [NSString stringWithFormat:@"%@_race%d", email, raceId];
    NSDictionary* units = @{@"label": @"speed", @"symbol": @"miles/hr"};
    __weak Race* weakSelf = self;
    [self.device updateStreamWithName:streamName
                           parameters:@{@"unit": units, @"type": @"numeric"}
                    completionHandler:^(M2XStream* s, M2XResponse* r) {
                        weakSelf.stream = s;
                        [weakSelf updateM2XStream];
                    }];
    
}

- (void)updateM2XStream
{
    if (!self.racing) {
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    NSLog(@"%@", iso8601String);
    
    NSNumber* number = [self.speedDataSource nextSimulatedSpeed];
    [self.stream updateValue:number
                   timestamp:iso8601String
           completionHandler:^(M2XResponse* response){
               NSLog(@"Posted something");
           }];

    [self.dataPoints addObject:number];
    [[NSNotificationCenter defaultCenter] postNotificationName:kM2XDataPointsChanged object:self];

    [self performSelector:@selector(updateM2XStream) withObject:nil afterDelay:4.0];
}

- (void)updateAndPostProgress
{
    if (self.raceState != RaceStateMiddleOfRace) {
        return;
    }
    
    AGSLocationDisplay* display = [[RaceMapView sharedMapView] locationDisplay];
    AGSPoint* newLocation = [display.mapLocation copy];
    
    [self.myProgress addPointToPath:newLocation];
    
    AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
    double lengthInMeters = [ge lengthOfGeometry:self.myProgress];
    _distanceInMiles = (lengthInMeters * kFeetPerMeter)/kFeetPerMile;
    
    NSLog(@"Lat:%f  Long:%f  Progress:  %.2f miles", newLocation.y, newLocation.x, _distanceInMiles);
}

- (NSString*)stringFromState:(RaceState)state
{
    NSString* s;
    switch (state) {
        case RaceStateUnknown:
            s = @"Unknown";
            break;
        case RaceStateNotStarted:
            s = @"Not started";
            break;
        case RaceStateAtStart:
            s = @"At start of race";
            break;
        case RaceStateLeftStart:
            s = @"Left start";
            break;
        case RaceStateMiddleOfRace:
            s = @"Middle of race";
            break;
        case RaceStateAtFinish:
            s = @"Arrived at finish line";
            break;
        case RaceStateFinishedRace:
            s = @"Done with race";
            break;
        default:
            break;
    }
    
    return s;
}

#pragma mark -
#pragma mark Key-Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kLocationPath]) {
        [self calculateRaceState];
    }
}

// ONly make sense when race is being run
- (double)distanceCovered
{
    if (self.raceState == RaceStateNotStarted ||  self.raceState == RaceStateUnknown) {
        return 0;
    }
    
    return self.distanceInMiles;
}

- (double)percentageComplete
{
    return (self.distanceInMiles / self.totalDistance)*100.0;
}

- (AGSPoint*)currentLocation
{
    return [[[RaceMapView sharedMapView] locationDisplay] mapLocation];
}

@end
