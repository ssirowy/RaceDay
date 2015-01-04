//
//  M2XKey.h
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XResource.h"

@interface M2XKey : M2XResource

// Retrieve list of keys associated with the user account.
//
// https://m2x.att.com/developer/documentation/v2/keys#List-Keys
+ (void)listWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler;

// Create a new API Key
//
// Note that, according to the parameters sent, you can create a
// Master API Key or a Device/Stream API Key.
//
// https://m2x.att.com/developer/documentation/v2/keys#Create-Key
+ (void)createWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XKeyCallback)completionHandler;

// Regenerate an API Key token
//
// Note that if you regenerate the key that you're using for
// authentication then you would need to change your scripts to
// start using the new key token for all subsequent requests.
//
// https://m2x.att.com/developer/documentation/v2/keys#Regenerate-Key
- (void)regenerateWithCompletionHandler:(M2XKeyCallback)completionHandler;

@end
