//
//  Tweet.m
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import "Tweet.h"
#import "User.h"

@implementation Tweet

#pragma mark - Mantle abstract methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tweetID": @"id",
             @"createdAt": @"created_at",
             @"user": @"user"
             };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:User.class];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    });

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [_dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [_dateFormatter stringFromDate:date];
    }];
}

@end
