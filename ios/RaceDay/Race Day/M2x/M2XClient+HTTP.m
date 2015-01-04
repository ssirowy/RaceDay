//
//  M2XClient+HTTP.m
//  M2XLib
//
//  Created by Luis Floreani on 11/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "M2XClient+HTTP.h"
#include <sys/types.h>
#include <sys/sysctl.h>

typedef void (^configureRequestBlock)(NSMutableURLRequest *request);

static BOOL VERBOSE_MODE = YES;

@implementation M2XClient (HTTP)

-(void)prepareUrlRequest:(NSMutableURLRequest *)request {
    [request setValue:self.apiKey forHTTPHeaderField:@"X-M2X-KEY"];
    
    NSString *agent = [self userAgent];
    [request setValue:agent forHTTPHeaderField:@"User-Agent"];
}

-(void)prepareUrlRequest:(NSMutableURLRequest *)request parameters:(NSDictionary *)parameters {
    NSArray *keys = [parameters allKeys];
    for (NSString *key in keys) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = nil;
        if ([parameters[key] respondsToSelector:@selector(stringByAddingPercentEscapesUsingEncoding:)])
            encodedValue = [parameters[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        else
            encodedValue = parameters[key];
        
        if (key == [keys firstObject]) {
            request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@=%@", request.URL, encodedKey, encodedValue]];
        } else {
            request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@=%@", request.URL, encodedKey, encodedValue]];
        }
    }
}

-(NSURLRequest *)performRequestOnPath:(NSString*)path parameters:(NSDictionary*)parameters configureRequestBlock:(configureRequestBlock)configureRequestBlock completionHandler:(M2XBaseCallback)completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.apiUrl, path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self prepareUrlRequest:request];
    if (configureRequestBlock) {
        configureRequestBlock(request);
    }
    
    if (!completionHandler) {
        return request;
    }
    
    if (VERBOSE_MODE) {
        NSLog(@"M2X: %@", request.URL);
    }
    
    M2XResponseCallback callback = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completionHandler) {
            if (self.delegate) {
                [self.delegate handleResponseWithData:data request:request response:(NSHTTPURLResponse *)response error:error completionHandler:completionHandler];
            } else {
                M2XResponse *r = [[M2XResponse alloc] initWithResponse:(NSHTTPURLResponse *)response data:data error:error];
                completionHandler(r);
            }
        }
    };
    
    if ([self.delegate respondsToSelector:@selector(handleRequest:completionHandler:)]
        && [self.delegate respondsToSelector:@selector(canHandleRequest:)]
        && [self.delegate canHandleRequest:request]) {
        [self.delegate handleRequest:request completionHandler:callback];
    } else {
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:callback];
        [task resume];
    }
    
    return request;
}

#pragma mark - Http methods

-(NSURLRequest *)getWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler {
    if (!self.apiKey) {
        NSError *error = [NSError errorWithDomain:M2XErrorDomain code:M2XApiErrorNoApiKey userInfo:@{NSLocalizedDescriptionKey: @"Missing API key"}];
        if (completionHandler) {
            completionHandler([[M2XResponse alloc] initWithResponse:nil data:nil error:error]);
        }
        return nil;
    }
    
    return [self performRequestOnPath:path parameters:parameters configureRequestBlock:^(NSMutableURLRequest *request) {
        [self prepareUrlRequest:request parameters:parameters];
    } completionHandler:completionHandler];
}

-(NSURLRequest *)postWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler {
    if (!self.apiKey) {
        NSError *error = [NSError errorWithDomain:M2XErrorDomain code:M2XApiErrorNoApiKey userInfo:@{NSLocalizedDescriptionKey: @"Missing API key"}];
        if (completionHandler) {
            completionHandler([[M2XResponse alloc] initWithResponse:nil data:nil error:error]);
        }
        return nil;
    }
    
    NSError *error = nil;
    NSData *postData = nil;
    if (parameters) {
        postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    }
    
    if (error) {
        completionHandler([[M2XResponse alloc] initWithResponse:nil data:nil error:error]);
        return nil;
    }
    
    return [self performRequestOnPath:path parameters:parameters configureRequestBlock:^(NSMutableURLRequest *request) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        
        if (postData) {
            [request setHTTPBody:postData];            
        }
    } completionHandler:completionHandler];
}

-(NSURLRequest *)putWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler {
    if (!self.apiKey) {
        NSError *error = [NSError errorWithDomain:M2XErrorDomain code:M2XApiErrorNoApiKey userInfo:@{NSLocalizedDescriptionKey: @"Missing API key"}];
        if (completionHandler) {
            completionHandler([[M2XResponse alloc] initWithResponse:nil data:nil error:error]);
        }
        return nil;
    }
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    if (error) {
        completionHandler([[M2XResponse alloc] initWithResponse:nil data:nil error:error]);
        return nil;
    }
    
    return [self performRequestOnPath:path parameters:parameters configureRequestBlock:^(NSMutableURLRequest *request) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"PUT"];
        [request setHTTPBody:postData];
    } completionHandler:completionHandler];
}

-(NSURLRequest *)deleteWithPath:(NSString*)path parameters:(NSDictionary*)parameters completionHandler:(M2XBaseCallback)completionHandler {
    if (!self.apiKey) {
        NSError *error = [NSError errorWithDomain:M2XErrorDomain code:M2XApiErrorNoApiKey userInfo:@{NSLocalizedDescriptionKey: @"Missing API key"}];
        if (completionHandler) {
            completionHandler([[M2XResponse alloc] initWithResponse:nil data:nil error:error]);
        }
        return nil;
    }
    
    return [self performRequestOnPath:path parameters:parameters configureRequestBlock:^(NSMutableURLRequest *request) {
        [request setHTTPMethod:@"DELETE"];
        [self prepareUrlRequest:request parameters:parameters];
    } completionHandler:completionHandler];
}

@end
