//
//  Races.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "Races.h"
#import "Race.h"
#import "SmiSdk.h"
#import <ArcGIS/ArcGIS.h>

static Races* sharedRaces = nil;

@interface Races() <AGSQueryTaskDelegate>

@property (nonatomic, strong) AGSQueryTask* queryTask;
@property (nonatomic, copy) void (^completion)(NSArray*, NSError*);

@property (nonatomic, strong) SmiResult* result;

@end
@implementation Races

- (id)init
{
    self = [super init];
    if (self) {
        _credential = [[AGSCredential alloc] initWithUser:@"scottsirowy" password:@"Crowded2000"];
        _url   = [NSURL URLWithString:kRaceServerURL];
        
        
        /*
        _result = [SmiSdk getSDAuth:kRaceServerURL userId:@"ssirowy" appId:@"RaceDay"];
        
        // get sponsored data url
        NSString* sdUrl =  self.result.url;
        if(self.result.state == SD_WIFI) {
            //wifi connection
        } else if (self.result.state == SD_AVAILABLE) {
            
            _url = [NSURL URLWithString:sdUrl];
            //1. use 'http://s3.amazonaws.com/sdmsg/sponsored/msg.png' logo to display sponsored message
            //2. use the 'sdUrl' for requesting the content } else if(sr.state == SD_NOT_AVAILABLE) {
        }  */
        
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
