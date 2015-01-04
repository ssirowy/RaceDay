//
//  DetailsViewController.h
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Race;

@interface DetailsViewController : UIViewController

@property (nonatomic, strong) Race* race;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;

@end
