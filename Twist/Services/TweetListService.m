//
//  TweetListService.m
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import "TweetListService.h"
#import "Tweet.h"
#import "TwitterAPIManager.h"

@interface TweetListService ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) NSNumber *minID;

@end

@implementation TweetListService

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tweets = [NSMutableArray new];
        self.minID = nil;
    }
    return self;
}

#pragma mark - API

- (NSInteger)count {
    return self.tweets.count;
}

- (Tweet *)objectAtIndexedSubscript:(NSUInteger)index {
    return self.tweets[index];
}

- (void)removeAllTweets {
    [self.tweets removeAllObjects];
}

- (void)loadFirst:(BOOL)first completion:(void (^)(NSArray *indexPaths, NSError *error))completion {
    if (first) {
        self.minID = nil;
    }
    @weakify(self);
    [[TwitterAPIManager sharedTwitterAPIManager] fetchTimelineFromID:self.minID completion:^(NSArray *tweets, NSError *error) {
        @strongify(self);
        if (tweets) {
            if (first) {
                [self removeAllTweets];
            }
            NSUInteger oldCount = self.tweets.count;
            NSUInteger newCount = tweets.count;
            NSMutableArray *indexPaths = [NSMutableArray new];
            if (newCount > 0) {
                [self.tweets addObjectsFromArray:tweets];
                self.minID = [tweets valueForKeyPath:@"@min.tweetID"];
                for (NSUInteger i = 0; i < newCount; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:(i + oldCount) inSection:0]];
                }
            }
            completion(indexPaths.copy, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
