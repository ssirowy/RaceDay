//
//  User.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "User.h"

static User* sharedUser = nil;

@implementation User


- (id)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        _email = email;
        
        // Store email and locked
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:email forKey:UserDefaultsEmailKey];
        [defaults synchronize];
        
        sharedUser = self;
    }
    
    return self;
}

// Can return nil if there is no stored user on device
+ (User*)storedUser {
    
    if (sharedUser) {
        return sharedUser;
    }
    
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:UserDefaultsEmailKey];
    BOOL locked = [defaults boolForKey:UserDefaultsLockedKey];
    Stats* stats = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults dataForKey:UserDefaultsStatsKey]];
    
    if (email) {
        sharedUser = [[User alloc] initWithEmail:email stats:stats home:nil work:nil locked:locked];
        return sharedUser;
    }   */
    
    return nil;
}

+ (void)signOutStoredUser
{
    // Clear entry in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:UserDefaultsEmailKey];
    [defaults synchronize];
    sharedUser = nil;
}

@end
