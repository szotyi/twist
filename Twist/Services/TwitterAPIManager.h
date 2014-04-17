//
//  TwitterAPIManager.h
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

@interface TwitterAPIManager : NSObject

@property (nonatomic, readonly) BOOL userHasAccessToTwitter;

+ (TwitterAPIManager *)sharedTwitterAPIManager;

- (void)fetchTimelineFromID:(NSNumber *)fromID completion:(void (^)(NSArray *tweets, NSError *error))completion;

@end
