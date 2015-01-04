//
//  NSDate+M2X.m
//  M2X_iOS
//
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "NSDate+M2X.h"

@implementation NSDate (M2X)

- (NSString *) toISO8601
{
    return [self toISO8601WithTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"] locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
}

- (NSString *) toISO8601WithTimeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale
{
    NSDateFormatter *df = [NSDateFormatter new];
    df.locale = locale;
    df.timeZone = timeZone;
    df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return [df stringFromDate:self];
}

+ (NSDate *) fromISO8601:(NSString *)dateString
{
    return [self fromISO8601:dateString timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"] locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
}

+ (NSDate *) fromISO8601:(NSString *)dateString timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = locale;
    df.timeZone = timeZone;
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    return [df dateFromString:dateString];
}

@end
