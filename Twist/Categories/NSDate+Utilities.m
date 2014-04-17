//
//  NSDate+Utilities.m
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

- (NSString *)tweetFormat {
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    });
    
    NSTimeInterval timeInterval = -1 * [self timeIntervalSinceNow];
    
    NSString *string = nil;
    if (timeInterval < 60) {
        string = @"now";
    } else if (timeInterval < 60*60) {
        NSInteger minute = floor(timeInterval/60);
        string = [NSString stringWithFormat:@"%ldm", (long)minute];
    } else if (timeInterval < 60*60*24){
        NSInteger hour = floor(timeInterval/60/60);
        string = [NSString stringWithFormat:@"%ldh", (long)hour];
    } else {
        NSInteger day = floor(timeInterval/60/60/24);
        string = [NSString stringWithFormat:@"%ldd", (long)day];
    }
    return string;
}

@end
