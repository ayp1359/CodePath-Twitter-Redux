//
//  Tweet.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/28/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject
@property (nonatomic,assign) NSInteger retweetCount;
@property (nonatomic,assign) NSInteger favoriteCount;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSDate *createdAt;
@property (nonatomic,strong) User *user;
@property (nonatomic,assign) unsigned long long tweetID;
@property (nonatomic,strong) User *retweetedByUser;
@property (nonatomic,assign) BOOL favorited;
@property (nonatomic,assign) BOOL retweeted;
@property (nonatomic,assign) unsigned long long myRetweetId;
- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)tweetsWithArray: (NSArray *)array;
@end
