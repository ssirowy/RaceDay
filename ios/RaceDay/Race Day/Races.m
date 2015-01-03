//
//  Races.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "Races.h"
#import <ArcGIS/ArcGIS.h>

static Races* sharedRaces = nil;

@interface Races() <AGSQueryTaskDelegate>

@property (nonatomic, strong) AGSQueryTask* queryTask;

@end
@implementation Races

- (id)init
{
    self = [super init];
    if (self) {
        _credential = [[AGSCredential alloc] initWithUser:@"scottsirowy" password:@"Crowded2000"];
        _url   = [NSURL URLWithString:kRaceServerURL];
    }
    
    return self;
}

+ (Races*)sharedRaces
{
    if (!sharedRaces) {
        sharedRaces = [[Races alloc] init];
    }
    
    return sharedRaces;
}

- (void)findRaces
{
    _queryTask = [[AGSQueryTask alloc] initWithURL:self.url credential:self.credential];
    AGSQuery* query = [AGSQuery query];
    query.whereClause = @"1=1";
    query.outFields = @[@"*"];
    query.returnGeometry = YES;
    query.outSpatialReference =  [AGSSpatialReference webMercatorSpatialReference];
    
    self.queryTask.delegate = self;
    [self.queryTask executeWithQuery:query];
}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet
{
    NSLog(@"Found some races");
}

@end
