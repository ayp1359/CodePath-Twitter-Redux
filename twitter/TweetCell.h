//
//  TweetCell.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/31/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol TweetCellDelegate <NSObject>

@end

@interface TweetCell : UITableViewCell
@property (nonatomic,strong) Tweet* tweet;
@property id<TweetCellDelegate> delegate;
-(CGFloat) estimateHeight:(Tweet *)tweetText;
@end
