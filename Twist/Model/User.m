//
//  User.m
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import "User.h"

@implementation User

#pragma mark - Mantle abstract methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userID": @"id",
             @"screenName": @"screen_name",
             @"avatarNormalURL": @"profile_image_url"
             };
}

+ (NSValueTransformer *)avatarNormalURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
