//
//  M2XResource.h
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2XClient.h"
#import "M2XClient+HTTP.h"

@interface M2XResource : NSObject

@property (nonatomic, strong) NSDictionary *attributes;
@property (readonly) M2XClient *client;

- (instancetype)initWithClient:(M2XClient *)client attributes:(NSDictionary *)attributes;

// must override
- (NSString *)path;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;

- (void)viewWithCompletionHandler:(M2XResourceCallback)completionHandler;

- (void)updateWithParameters:(NSDictionary *)parameters completionHandler:(M2XResourceCallback)completionHandler;

- (void)deleteWithCompletionHandler:(M2XBaseCallback)completionHandler;

@end
