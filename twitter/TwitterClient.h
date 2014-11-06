//
//  TwitterClient.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/27/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager
extern NSString * const kTwitterClientCallbackNotification;
extern NSString * const kTwitterClientCallbackURLKey;

+ (TwitterClient *)instance;
- (void)retweet:(Tweet*)tweet success:(void (^)(Tweet* tweet))success failure:(void (^)(NSError *error))failure;
- (void)unRetweet:(Tweet*) tweet success:(void (^)())success failure:(void (^)(NSError *))failure;
- (void)loginWithSuccess:(void (^)())success failure:(void (^)(NSError* error))failure;
- (void)currentUserWithSuccess:(void (^)(User* currentUser))success failure:(void (^)(NSError *error))failure;
- (void)userTimeLine:(User *) user success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
- (void)homeTimelineWithSuccess:(void (^)(NSArray* tweets))success failure:(void (^)(NSError *error))failure;
- (void)mentionsTimelineWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
- (void)postTweetWithText:(NSString*)text replyToTweetId:(NSNumber*)replyToId success:(void (^)(Tweet* tweet))success failure:(void (^)(NSError *error))failure;
- (void)toggleFavoriteForTweet:(Tweet *)tweet success:(void (^)(Tweet *))success failure:(void (^)(NSError *))failure;
@end
