//
//  M2XResponse.m
//  M2XLib
//
//  Created by Luis Floreani on 11/27/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XResponse.h"

NSString * const M2XErrorDomain = @"M2XErrorDomain";

@interface M2XResponse()

@property (strong) NSHTTPURLResponse *response;
@property (strong) NSData *data;
@property (strong) id jsonObject;

@end

@implementation M2XResponse

NSError *_errorObject;

- (instancetype)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error {
    self = [super init];
    
    if (self) {
        _response = response;
        _data = data;
        _errorObject = error;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _response = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
    }
    return self;
}

- (NSData *)raw {
    return _data;
}

- (id)json {
    if (_jsonObject == nil && [_data length] > 0) {
        _jsonObject = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
    }
    
    return _jsonObject;
}

- (NSInteger)status {
    return _response.statusCode;
}

- (NSDictionary *)headers {
    return _response.allHeaderFields;
}

- (BOOL)success {
    return !_errorObject && _response.statusCode >= 200 && _response.statusCode <= 299;
}

- (BOOL)clientError {
    return _errorObject || (_response.statusCode >= 400 && _response.statusCode <= 499);
}

- (BOOL)serverError {
    return _errorObject || (_response.statusCode >= 500 && _response.statusCode <= 599);
}

- (BOOL)error {
    return self.clientError || self.serverError;
}

- (NSError *)errorObject {
    if (_errorObject) {
        return _errorObject;
    } else if ([self error]) {
        NSString *desc = [NSString stringWithFormat:@"HTTP Status Code: %@", [NSNumber numberWithInt:(int)_response.statusCode]];
        NSMutableDictionary *userInfo = [@{NSLocalizedDescriptionKey: desc} mutableCopy];
        NSString *message = [[self json] valueForKey:@"message"];
        if (message) {
            userInfo[NSLocalizedFailureReasonErrorKey] = [self json][@"message"];
        }
        return [NSError errorWithDomain:M2XErrorDomain code:M2XApiErrorResponseErrorKey userInfo:userInfo];
    } else {
        return nil;
    }
}

@end
