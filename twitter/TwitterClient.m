//
//  TwitterClient.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/27/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <NSDictionary+BDBOAuth1Manager.h>
#import "TwitterClient.h"

static NSString * const kTwitterAPIKey = @"KC10IUWkp4ObmCQ0ReAlPB5W1";
static NSString * const kTwitterAPISecret = @"IhCgHTlixnRrnt8lopcCGvlO3Hgy0lDoWtO7HJoyyKhRSiTxJO";
static NSString * const kCallbackURLScheme = @"codepathtwitter";
static NSString * const kCallbackURLHost = @"request_token";
static NSString * const kAccessTokenKey = @"com.codepath.twitter.access_token";

NSString * const kTwitterClientCallbackNotification = @"com.codepath.twitter.notification.oauth.callback";
NSString * const kTwitterClientCallbackURLKey = @"com.codepath.twitter.notification.oauth.urlkey";

@interface TwitterClient ()
@property (nonatomic, strong) id applicationLaunchNotificationObserver;
@end

@implementation TwitterClient

+ (TwitterClient *)instance {
  static dispatch_once_t once;
  static TwitterClient *instance;
  
  dispatch_once(&once, ^{
    instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/"]
                                          consumerKey:kTwitterAPIKey
                                       consumerSecret:kTwitterAPISecret];
  });
  
  return instance;
}

- (void)loginWithSuccess:(void (^)())success failure:(void (^)(NSError* error))failure;
{
  [self removeAccessToken];
  [self fetchRequestTokenWithPath:@"oauth/request_token"
                           method:@"POST"
                      callbackURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", kCallbackURLScheme, kCallbackURLHost]]
                            scope:nil
                          success:^(BDBOAuthToken *requestToken) {
                            [self requestAccessTokenWithRequestToken:requestToken success:success failure:failure];
                          }
                          failure:^(NSError *error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            failure(error);
                          }];
}

- (void)currentUserWithSuccess:(void (^)(User* currentUser))success failure:(void (^)(NSError *error))failure
{
  [self GET:@"1.1/account/verify_credentials.json"
 parameters:nil
    success:^(AFHTTPRequestOperation *operation, id response){
      User* currentUser = [[User alloc] initWithDictionary:response];
      success(currentUser);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"%@", error);
      failure(error);
    }];
}

- (void)userTimeLine:(User *) user success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
  [self timeline:@"1.1/statuses/user_timeline.json" success:success failure:failure params:@{@"user_id": [NSNumber numberWithInteger:user.userId]}];
}

- (void)homeTimelineWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
  [self timeline:@"1.1/statuses/home_timeline.json" success:success failure:failure params:nil];
}

- (void)mentionsTimelineWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
  [self timeline:@"1.1/statuses/mentions_timeline.json" success:success failure:failure params:nil];
}

- (void)postTweetWithText:(NSString*)text replyToTweetId:(NSNumber*)replyToId success:(void (^)(Tweet* tweet))success failure:(void (^)(NSError *error))failure
{
  NSDictionary *params;
  
  if (replyToId) {
    params = @{@"status": text, @"in_reply_to_status_id": replyToId};
  } else {
    params = @{@"status": text};
  }
  
  [self POST:@"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *response = (NSDictionary*) responseObject;
      //            NSLog(@"%@", response);
      Tweet *tweet = [[Tweet alloc] initWithDictionary:response];
      success(tweet);
    } else {
      failure([NSError errorWithDomain:@"Post Tweet" code:400 userInfo:nil]);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  }];
}

- (BDBOAuthToken*) accessToken
{
  NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kAccessTokenKey];
  if (data) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
  }
  return nil;
}

- (void)saveAccessToken:(BDBOAuthToken *)accessToken
{
  [self.requestSerializer saveAccessToken:accessToken];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
  [userDefaults setObject:data forKey:kAccessTokenKey];
  [userDefaults synchronize];
}

- (void)removeAccessToken
{
  [self.requestSerializer removeAccessToken];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults removeObjectForKey:kAccessTokenKey];
  [userDefaults synchronize];
}

- (void)toggleFavoriteForTweet:(Tweet *)tweet success:(void (^)(Tweet *))success failure:(void (^)(NSError *))failure
{
  NSString* resource;
  if (tweet.favorited) {
    resource = @"1.1/favorites/destroy.json";
    tweet.favorited = NO;
    tweet.favoriteCount--;
  } else {
    resource = @"1.1/favorites/create.json";
    tweet.favorited = YES;
    tweet.favoriteCount++;
  }
  NSDictionary *params = @{@"id": [NSNumber numberWithLongLong:tweet.tweetID]};
  
  [self POST:resource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *response = (NSDictionary*) responseObject;
      //            NSLog(@"%@", response);
      Tweet *tweet = [[Tweet alloc] initWithDictionary:response];
      if (success) success(tweet);
    } else {
      if (failure) failure([NSError errorWithDomain:@"Post Tweet" code:400 userInfo:nil]);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (failure) failure(error);
  }];
}

- (void) retweet:(Tweet *)tweet success:(void (^)(Tweet *))success failure:(void (^)(NSError *))failure
{
  if (tweet.retweeted) {
    if (failure) failure([NSError errorWithDomain:@"Already retweeted." code:400 userInfo:nil]);
  }
  
  tweet.retweeted = YES;
  tweet.retweetCount++;
  
  NSString *retweetResource = [NSString stringWithFormat:@"1.1/statuses/retweet/%lld.json", tweet.tweetID];
  NSDictionary *params = @{@"id": [NSNumber numberWithLongLong:tweet.tweetID]};
  
  [self POST:retweetResource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *response = (NSDictionary*) responseObject;
      //            NSLog(@"%@", response);
      Tweet *tweet = [[Tweet alloc] initWithDictionary:response];
      if (success) success(tweet);
    } else {
      if (failure) failure([NSError errorWithDomain:@"Post Tweet" code:400 userInfo:nil]);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (failure) failure(error);
  }];
}

- (void) unRetweet:(Tweet*) tweet success:(void (^)())success failure:(void (^)(NSError *))failure
{
  if (!tweet.retweeted) {
    if (failure) failure([NSError errorWithDomain:@"Cannot unretweet" code:400 userInfo:nil]);
  }
  
  
  tweet.retweeted = NO;
  tweet.retweetCount--;
  
  NSDictionary *params = @{@"id": [NSNumber numberWithLongLong:tweet.tweetID], @"include_my_retweet": [NSNumber numberWithBool:YES]};
  
  [self GET:@"1.1/statuses/show.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *response = (NSDictionary*) responseObject;
      Tweet *tweet = [[Tweet alloc] initWithDictionary:response];
      [self deleteTweetWithId:tweet.myRetweetId success:success failure:failure];
      
    } else {
      if (failure) failure([NSError errorWithDomain:@"Post Tweet" code:400 userInfo:nil]);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (failure) failure(error);
  }];
}

#pragma mark - Private methods
- (void)timeline:(NSString*)resource success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure params:(NSDictionary *)params
{
  [self GET:resource
 parameters:params
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
      if ([responseObject isKindOfClass:[NSArray class]]) {
        NSArray *response = (NSArray*) responseObject;
        NSMutableArray *parsedTweets = [[NSMutableArray alloc] initWithCapacity:response.count];
        for (NSDictionary *tweetDict in response) {
          Tweet* tweet = [[Tweet alloc] initWithDictionary:tweetDict];
          [parsedTweets addObject:tweet];
        }
        success(parsedTweets);
      } else {
        failure([NSError errorWithDomain:@"Home Timeline" code:400 userInfo:nil]);
      }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      failure(error);
    }];
}

- (void) deleteTweetWithId:(unsigned long long)tweetId success:(void (^)())success failure:(void (^)(NSError *))failure
{
  NSString *deleteResource = [NSString stringWithFormat:@"1.1/statuses/destroy/%lld.json", tweetId];
  NSDictionary *params = @{@"id": [NSNumber numberWithLongLong:tweetId]};
  [self POST:deleteResource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     if (success) success();
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     if (failure) failure(error);
   }];
}

- (void) requestAccessTokenWithRequestToken:(BDBOAuthToken*)requestToken
                                    success:(void (^)())success
                                    failure:(void (^)(NSError* error))failure
{
  self.applicationLaunchNotificationObserver = [[NSNotificationCenter defaultCenter]
                                                addObserverForName:kTwitterClientCallbackNotification
                                                object:nil
                                                queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *notification) {
                                                  [self handleApplicationCallbackWithNotification:notification success:success failure:failure];
                                                }];
  
  NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
}

- (void) handleApplicationCallbackWithNotification:(NSNotification*)notification
                                           success:(void (^)())success
                                           failure:(void (^)(NSError* error))failure
{
  NSURL *url = [[notification userInfo] valueForKey:kTwitterClientCallbackURLKey];
  if ([url.scheme isEqualToString:kCallbackURLScheme] && [url.host isEqualToString:kCallbackURLHost])
  {
    NSDictionary *parameters = [NSDictionary dictionaryFromQueryString:url.query];
    if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]) {
      [self fetchAccessTokenWithPath:@"/oauth/access_token"
                              method:@"POST"
                        requestToken:[BDBOAuthToken tokenWithQueryString:url.query]
                             success:^(BDBOAuthToken *accessToken) {
                               [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchNotificationObserver];
                               self.applicationLaunchNotificationObserver = nil;
                               [self saveAccessToken:accessToken];
                               success();
                             }
                             failure:^(NSError* error) {
                               NSLog(@"Error during access token: %@", error.localizedDescription);
                               [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchNotificationObserver];
                               self.applicationLaunchNotificationObserver = nil;
                               failure(error);
                             }];
    }
  }
}


@end
