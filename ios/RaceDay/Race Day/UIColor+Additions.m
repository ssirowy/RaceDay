//
//  UIColor+Additions.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "UIColor+Additions.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0f \
green:       ((rgbValue & 0x00FF00) >>  8)/255.0f \
blue:        ((rgbValue & 0x0000FF) >>  0)/255.0f \
alpha:       1.0]

@implementation UIColor (Additions)

+ (UIColor*)darkOrange
{
    return UIColorFromRGB(0xAB4600);
    
}

+ (UIColor*)darkBlue
{
    return UIColorFromRGB(0x576E91);
}

@end
