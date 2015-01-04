//
//  M2XKey.m
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XKey.h"

static NSString * const kPath = @"/keys";

@implementation M2XKey

+ (void)listWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XArrayCallback)completionHandler {
    [client getWithPath:kPath parameters:parameters completionHandler:^(M2XResponse *response) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in response.json[@"keys"]) {
            M2XKey *key = [[M2XKey alloc] initWithClient:client attributes:dict];
            [array addObject:key];
        }
        
        completionHandler(array, response);
    }];
}

+ (void)createWithClient:(M2XClient *)client parameters:(NSDictionary *)parameters completionHandler:(M2XKeyCallback)completionHandler {
    [client postWithPath:kPath parameters:parameters completionHandler:^(M2XResponse *response) {
        M2XKey *key = [[M2XKey alloc] initWithClient:client attributes:response.json];
        completionHandler(key, response);
    }];
}

- (void)regenerateWithCompletionHandler:(M2XKeyCallback)completionHandler {
    [self.client postWithPath:[NSString stringWithFormat:@"%@/regenerate", [self path]] parameters:nil completionHandler:^(M2XResponse *response) {
        self.attributes = response.json;
        completionHandler(self, response);
    }];
}

- (NSString *)path {
    return [NSString stringWithFormat:@"%@/%@", kPath, [self[@"key"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
