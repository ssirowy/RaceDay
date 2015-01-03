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

#define kFeetPerMeter 3.28084
#define kFeetPerMile  5280

typedef enum {
    RaceStateUnknown = 0,
    RaceStateNotStarted,
    RaceStateAtStart,
    RaceStateLeftStart,
    RaceStateMiddleOfRace,
    RaceStateAtFinish,
    RaceStateFinishedRace
} RaceState;

@interface Race()

@property (nonatomic, strong) AGSPolyline* raceLine;

@property (nonatomic, assign) RaceState raceState;

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


#define kFast 60
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
    
    AGSPolyline* densifiedLine = (AGSPolyline*)[engine densifyGeometry:self.raceLine withMaxSegmentLength:maxLength];
    densifiedLine = (AGSPolyline*)[engine projectGeometry:densifiedLine toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    AGSSimulatedLocationDisplayDataSource* dataSource = [[AGSSimulatedLocationDisplayDataSource alloc] init];
    [dataSource setLocationsFromPolyline:densifiedLine];
    
    AGSLocationDisplay* display = [[RaceMapView sharedMapView] locationDisplay];
    display.dataSource = dataSource;
    [display startDataSource];
    
    [display addObserver:self forKeyPath:kLocationPath options:0 context:nil];
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
            break;
        case RaceStateMiddleOfRace:
            break;
        case RaceStateAtFinish:
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
    
    NSLog(@"%@", [self stringFromState:self.raceState]);
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
            s = @"Arrived P1";
            break;
        case RaceStateFinishedRace:
            s = @"At P2";
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

@end
