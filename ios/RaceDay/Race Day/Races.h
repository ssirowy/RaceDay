//
//  Races.h
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

#define kRaceServerURL @"http://services1.arcgis.com/W4Noi4OZras42xbd/arcgis/rest/services/Races/FeatureServer/0"

@interface Races : NSObject

@property (nonatomic, strong, readonly) AGSCredential* credential;
@property (nonatomic, strong, readonly) NSURL* url;

@property (nonatomic) BOOL usingSponsoredData;

@property (nonatomic, strong, readonly) NSArray* allRaces;

- (void)findRacesWithCompletion:(void (^)(NSArray*, NSError*))completion;

+ (Races*)sharedRaces;

@end
