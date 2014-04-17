//
//  TwitterAPIManager.m
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import "TwitterAPIManager.h"
@import Accounts;
@import Social;
#import <Mantle.h>
#import "Tweet.h"

@interface TwitterAPIManager ()

@property (nonatomic, strong) ACAccountStore *accountStore;

@end

@implementation TwitterAPIManager

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

#pragma mark - Twitter API

- (BOOL)userHasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchTimelineFromID:(NSNumber *)fromID completion:(void (^)(NSArray *tweets, NSError *error))completion {
    if (self.userHasAccessToTwitter) {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];

        @weakify(self)
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            @strongify(self)
             if (granted) {
                 NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 ACAccount *account = [twitterAccounts lastObject];
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                 NSMutableDictionary *params = [@{@"screen_name" : account.username,
                                                  @"include_rts" : @"1",
                                                  @"count" : @"20"} mutableCopy];
                 if (fromID) {
                     params[@"max_id"] = [NSString stringWithFormat:@"%@", @(fromID.longLongValue - 1)];
                 }
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 [request setAccount:account];
                 
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     if (responseData) {
                         if (urlResponse.statusCode >= 200 &&
                             urlResponse.statusCode < 300) {
                             NSError *jsonError;
                             NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                             if (timelineData) {
                                 NSMutableArray *tweets = [NSMutableArray new];
                                 for (NSDictionary *tweet in timelineData) {
                                     NSError *mtlError = nil;
                                     [tweets addObject:[MTLJSONAdapter modelOfClass:Tweet.class fromJSONDictionary:tweet error:&mtlError]];
                                 }
                                 completion(tweets.copy, nil);
                             } else {
                                 completion(nil, jsonError);
                             }
                         } else {
                             NSError *error = [NSError errorWithDomain:@"eu.imind.BadStatusCode" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The response status code is %d", urlResponse.statusCode]}];
                             completion(nil, error);
                         }
                     }
                  }];
             } else {
                 completion(nil, error);
             }
         }];

    } else {
        NSError *error = [NSError errorWithDomain:@"eu.imind.NoTwitterUser" code:0 userInfo:@{NSLocalizedDescriptionKey: @"A Twitter account is needed,\nyou can setup yours in the Settings.app"}];
        completion(nil, error);
    }
}

#pragma mark - Singleton Instance methods

+ (TwitterAPIManager *)sharedTwitterAPIManager {
    static TwitterAPIManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TwitterAPIManager alloc] init];
    });
    return sharedInstance;
}

@end
