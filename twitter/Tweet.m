//
//  Tweet.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/28/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary{
  
  self = [super init];
  
  if(self){
    self.tweetID = [dictionary[@"id"] longLongValue];
    NSDictionary *retweet = dictionary[@"retweeted_status"];
    if (retweet) {
      self.retweetedByUser = [[User alloc] initWithDictionary:dictionary[@"user"]];
      self.user = [[User alloc] initWithDictionary:retweet[@"user"]];
      self.text = retweet[@"text"];
    } else {
      self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
      self.text = dictionary[@"text"];
    }
    
    NSString *createdAtString = dictionary[@"created_at"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
    self.createdAt = [formatter dateFromString:createdAtString];
    self.retweetCount = [dictionary[@"retweet_count"] integerValue];
    self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
    self.favorited = [dictionary[@"favorited"] boolValue];
    self.retweeted = [dictionary[@"retweeted"] boolValue];
    if ([dictionary[@"current_user_retweet"] isKindOfClass:[NSDictionary class]]) {
      self.myRetweetId = [(dictionary[@"current_user_retweet"][@"id"]) longLongValue];
    }
  }
  
  return self;
}

+ (NSArray *)tweetsWithArray: (NSArray *)array{
  NSMutableArray *tweets = [[NSMutableArray alloc] init];
  for (NSDictionary *dictionary in array){
    [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
  }
  return tweets;
}

@end
