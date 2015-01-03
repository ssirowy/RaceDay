//
//  Race.h
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface Race : NSObject

@property (nonatomic, strong, readonly) AGSGraphic* graphic;

- (id)initWithFeature:(AGSGraphic*)race;

- (NSString*)raceId;

- (NSString*)title;
- (NSDate*)startTime;
- (NSDate*)endDate;

@end
