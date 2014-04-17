//
//  TwistTableViewController.m
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import "TwistTableViewController.h"
#import "TweetListService.h"
#import "TwistTableViewCell.h"
#import "Tweet.h"
#import "User.h"
#import "NSDate+Utilities.h"
#import "Haneke.h"

@interface TwistTableViewController ()

@property (nonatomic, strong) TweetListService *tweetListService;
@property (nonatomic, assign) NSInteger rowForNextLoad;
@property (atomic, assign) BOOL isLoading;

- (void)refresh:(id)sender;
- (void)done;
- (void)load:(BOOL)first;

@end

@implementation TwistTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tweetListService = [[TweetListService alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self refresh:nil];
}

#pragma mark - Events

- (void)refresh:(id)sender {
    [self load:YES];
}

- (void)done {
    [self.refreshControl endRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.isLoading = NO;
}

- (void)load:(BOOL)first {
    if (!self.isLoading) {
        self.isLoading = YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        @weakify(self)
        [self.tweetListService loadFirst:first completion:^(NSArray *indexPaths, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                @strongify(self)
                [self done];
                if (indexPaths) {
                    if (indexPaths.count > 0) {
                        if (first) {
                            [self.tableView reloadData];
                            [self load:NO];
                            self.rowForNextLoad = self.tweetListService.count;
                        } else {
                            [self.tableView beginUpdates];
                            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.tableView endUpdates];
                            self.rowForNextLoad = self.tweetListService.count - indexPaths.count;
                        }
                    } else {
                        self.rowForNextLoad = INT32_MAX;
                    }
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            });
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetListService.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TwistTableViewCell";
    TwistTableViewCell *cell = (TwistTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    Tweet *tweet = self.tweetListService[indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ @%@", tweet.user.name, tweet.user.screenName];
    cell.tweetTextLabel.text = tweet.text;
    cell.dateLabel.text = tweet.createdAt.tweetFormat;
    cell.avatarView.layer.cornerRadius = 20.0;
    cell.avatarView.layer.masksToBounds = YES;
    cell.avatarView.layer.borderWidth = 0.5;
    cell.avatarView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
    cell.avatarView.image = nil;
    [cell.avatarView hnk_setImageFromURL:tweet.user.avatarNormalURL];
    
    if (indexPath.row >= self.rowForNextLoad) {
        [self load:NO];
    }

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweetListService[indexPath.row];
    CGRect rect = [tweet.text boundingRectWithSize:CGSizeMake(244, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
    return 32.0 + 12.0 + ceil(rect.size.height);
}

@end
