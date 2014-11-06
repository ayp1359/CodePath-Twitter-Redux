//
//  ComposeTweetViewController.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 11/05/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "TwitterClient.h"

//set notification constant keys
NSString * const kNewTweetPostedNotification = @"twitter.new_tweet";
NSString * const kNewTweetPostedNotificationKey = @"twitter.new_tweet.key";

@interface ComposeTweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property (strong, nonatomic) NSString* initialText;
@property (strong, nonatomic) NSNumber* replyToTweetId;
@end

@implementation ComposeTweetViewController

- (id)initWithTweetText:(NSString *)tweetText replyToTweetId:(NSNumber*)replyToTweetId {
  self = [super init];
  if (self) {
    self.initialText = tweetText;
    self.replyToTweetId = replyToTweetId;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tweetTextView.text = self.initialText;
  self.tweetTextView.delegate = self;
  [self.tweetTextView becomeFirstResponder];
  
  UIBarButtonItem *cancelButton= [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(cancelTweet)];
  
  UIBarButtonItem *tweetButton= [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(sendTweet)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItems = @[tweetButton];
  
  User* currentUser = [User currentUser];
  [self.profileImage setImageWithURL:currentUser.profileImageURL];
  self.userNameLabel.text = currentUser.name;
  self.userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
}


- (void)textViewDidChange:(UITextView *)textView {
  self.limitLabel.text = [NSString stringWithFormat:@"%lu", 140 - self.tweetTextView.text.length];
}

- (void)sendTweet {
  NSString* text = self.tweetTextView.text;
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  [[TwitterClient instance] postTweetWithText:text replyToTweetId:self.replyToTweetId success:^(Tweet *tweet) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewTweetPostedNotification object:self userInfo:@{kNewTweetPostedNotificationKey: tweet}];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.delegate sendTweet:tweet];
  } failure:^(NSError *error) {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
  }];
  
}

- (void)cancelTweet {
  [self.delegate cancelNewTweet];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
