//
//  M2XClient+HTTP.h
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XClient.h"

@interface M2XClient (HTTP)

-(NSURLRequest *)getWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler;
-(NSURLRequest *)postWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler;
-(NSURLRequest *)putWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler;
-(NSURLRequest *)deleteWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler;

@end
