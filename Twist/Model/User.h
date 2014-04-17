//
//  User.h
//  Twist
//
//  Created by Peter Kovacs on 20/03/14.
//  Copyright (c) 2014 iMind. All rights reserved.
//

#import <Mantle.h>

@interface User : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *userID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *screenName;
@property (nonatomic, copy, readonly) NSURL *avatarNormalURL;

@end
