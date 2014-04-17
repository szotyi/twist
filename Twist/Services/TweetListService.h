//
//  TweetListService.h
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

@class Tweet;

@interface TweetListService : NSObject

@property (nonatomic, readonly) NSInteger count;

- (Tweet *)objectAtIndexedSubscript:(NSUInteger)index;

- (void)removeAllTweets;

- (void)loadFirst:(BOOL)first completion:(void (^)(NSArray *indexPaths, NSError *error))completion;

@end
