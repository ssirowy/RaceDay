//
//  User.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultsEmailKey @"UserDefaultsEmail"
#define UserDefaultsLockedKey @"UserDefaultsLocked"

@class Stats;
@class Commute;
@class Incentives;

@interface User : NSObject

@property (nonatomic, readonly) NSString* email;

// Will overwrite any previous user on device
- (id)initWithEmail:(NSString *)email;

// Can return nil if there is no stored user on device
+ (User*)storedUser;

+ (void)signOutStoredUser;

@end
