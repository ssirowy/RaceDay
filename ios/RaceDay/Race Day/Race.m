//
//  Race.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "Race.h"
#import <ArcGIS/ArcGIS.h>

#define kFeetPerMeter 3.28084
#define kFeetPerMile  5280

@interface Race()

@property (nonatomic, strong) AGSPolyline* raceLine;

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

#define kBufferFactor 800
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

@end
