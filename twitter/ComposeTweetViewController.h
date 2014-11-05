//
//  ComposeTweetViewController.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 11/05/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

extern NSString * const NewTweetPostedNotification;
extern NSString * const NewTweetPostedNotificationKey;

@protocol ComposeTweetDelegate <NSObject>
- (void)sendTweet:(Tweet*) tweet;
- (void)cancelNewTweet;
@end

@interface ComposeTweetViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) id<ComposeTweetDelegate> delegate;
- (id)initWithTweetText:(NSString *)tweetText replyToTweetId:(NSNumber*)replyToTweetId;

@end
