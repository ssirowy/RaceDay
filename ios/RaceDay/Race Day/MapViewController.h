//
//  MapViewController.h
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Race;

@interface MapViewController : UIViewController

@property (nonatomic, assign) BOOL small;

- (void)showRace:(Race*)race;

@end
