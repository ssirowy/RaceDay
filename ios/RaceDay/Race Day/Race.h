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

@property (nonatomic, strong, readonly) NSNumber* raceID;
@property (nonatomic, strong, readonly) NSString* title;
@property (nonatomic, strong, readonly) NSDate*   startDate;
@property (nonatomic, strong, readonly) NSDate*   endDate;

// miles
@property (nonatomic, assign) CGFloat totalDistance;

- (id)initWithFeature:(AGSGraphic*)race;

@end
