//
//  RaceMapView.h
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface RaceMapView : AGSMapView

+ (RaceMapView*)sharedMapView;

@end
