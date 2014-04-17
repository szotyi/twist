//
//  Tweet.h
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import <Mantle.h>

@class User;

@interface Tweet : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *tweetID;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSDate *createdAt;

@property (nonatomic, strong, readonly) User *user;

@end
