//
//  M2XResource.m
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XResource.h"

@interface M2XResource()

@property (nonatomic, strong) M2XClient *client;

@end

@implementation M2XResource

- (instancetype)initWithClient:(M2XClient *)client attributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        _client = client;
        _attributes = attributes;
    }
    
    return self;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    return _attributes[key];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"InvalidInitializer" reason:@"Can't use the default initializer" userInfo:nil];
}

- (void)viewWithCompletionHandler:(M2XResourceCallback)completionHandler {
    [self.client getWithPath:[self path] parameters:nil completionHandler:^(M2XResponse *response) {
        self.attributes = response.json;
        completionHandler(self, response);
    }];
}

- (void)updateWithParameters:(NSDictionary *)parameters completionHandler:(M2XResourceCallback)completionHandler {
    [self.client putWithPath:[self path] parameters:parameters completionHandler:^(M2XResponse *response) {
        self.attributes = response.json;
        completionHandler(self, response);
    }];
}

- (void)deleteWithCompletionHandler:(M2XBaseCallback)completionHandler {
    [self.client deleteWithPath:[self path] parameters:nil completionHandler:^(M2XResponse *response) {
        completionHandler(response);
    }];
}

- (NSString *)path {
    @throw [NSException exceptionWithName:@"InvalidMethod" reason:@"You must override this" userInfo:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [self class], self.attributes];
}

@end
