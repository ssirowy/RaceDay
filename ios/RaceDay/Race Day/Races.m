//
//  Races.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "Races.h"
#import "Race.h"
#import <ArcGIS/ArcGIS.h>

static Races* sharedRaces = nil;

@interface Races() <AGSQueryTaskDelegate>

@property (nonatomic, strong) AGSQueryTask* queryTask;
@property (nonatomic, copy) void (^completion)(NSArray*, NSError*);

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

- (void)findRacesWithCompletion:(void (^)(NSArray*, NSError*))completion
{
    _queryTask = [[AGSQueryTask alloc] initWithURL:self.url credential:self.credential];
    AGSQuery* query = [AGSQuery query];
    query.whereClause = @"1=1";
    query.outFields = @[@"*"];
    query.returnGeometry = YES;
    query.outSpatialReference =  [AGSSpatialReference webMercatorSpatialReference];
    
    self.queryTask.delegate = self;
    [self.queryTask executeWithQuery:query];
    
    _completion = completion;
}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet
{
    NSMutableArray* races = [NSMutableArray array];
    for (AGSGraphic* g in featureSet.features) {
        Race* r = [[Race alloc] initWithFeature:g];
        [races addObject:r];
    }
    
    _allRaces = races;
    if (self.completion) {
        self.completion(races, nil);
        self.completion = nil;
    }
}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    if (self.completion) {
        self.completion(nil, error);
        self.completion = nil;
    }
}

@end
