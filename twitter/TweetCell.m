//
//  TweetCell.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/31/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <NSDate+DateTools.h>
#import "TweetCell.h"

@interface TweetCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetIndicatorTopOfCellSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetIndicatorHeight;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@end

@implementation TweetCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}


- (void)setTweet:(Tweet *)tweet {
  _tweet = tweet;
  [self refreshView];
}

- (void) refreshView {
  Tweet* tweet = self.tweet;
  if (tweet.retweetedByUser)
  {
    self.retweetLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweetedByUser.name];
    self.retweetIndicatorTopOfCellSpacing.constant = 13.0f;
    self.retweetIndicatorHeight.constant = 16.0f;
  } else {
    self.retweetIndicatorTopOfCellSpacing.constant = 8.0f;
    self.retweetIndicatorHeight.constant = 0.0f;
  }
  
  [self.profileImageView setImageWithURL:tweet.user.profileImageURL];
  
  self.nameLabel.text = tweet.user.name;
  self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
  self.createdAtLabel.text = tweet.createdAt.shortTimeAgoSinceNow;
  self.tweetTextLabel.text = tweet.text;
  self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweet.retweetCount];
  self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweet.favoriteCount];
  
  if (tweet.favorited) {
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
  } else {
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_default"] forState:UIControlStateNormal];
  }
  
  if (tweet.retweeted) {
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
  } else {
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet_default"] forState:UIControlStateNormal];
  }
}

- (CGFloat) estimateHeight:(Tweet *)tweet {
  //some manual autolayout stuff here
  CGFloat h = 0.0f;
  h += 13;
  
  if (tweet.retweetedByUser) {
    h += 21;
  }
  
  h += 16;
  h += 5;
  
  CGSize maximumTextLabelSize = CGSizeMake(self.tweetTextLabel.frame.size.width, MAXFLOAT);
  CGRect nameRect = [tweet.text boundingRectWithSize:maximumTextLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.tweetTextLabel.font} context:nil];
  h += nameRect.size.height;
  
  h += 8;
  h += 16;
  h += 13;
  
  return h;
}
@end
