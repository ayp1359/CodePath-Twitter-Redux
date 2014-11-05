//
//  User.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/28/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CurrentUserSetNotification;
extern NSString * const CurrentUserRemovedNotification;

@interface User : NSObject<NSCoding>
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong) NSURL *bannerImageURL;
@property (nonatomic, assign) NSInteger tweetCount;
@property (nonatomic, assign) NSInteger followerCount;
@property (nonatomic, assign) NSInteger followingCount;
- (instancetype)initWithDictionary:(NSDictionary*) dict;
+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;
+ (void)removeCurrentUser;
@end
