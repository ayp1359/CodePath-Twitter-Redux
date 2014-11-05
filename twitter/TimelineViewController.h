//
//  TimelineViewController.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/31/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTweetViewController.h"
#import "TweetTableViewController.h"
#import "TweetCell.h"

@interface TimelineViewController : UIViewController<ComposeTweetDelegate,TweetTableViewDelegate>
@property (strong, nonatomic) NSMutableArray* tweets;
- (id) initWithDataLoadingBlockWithSuccessFailure:(void (^)(void (^success)(NSArray *), void (^failure)(NSError *))) block;
- (void) refetchTweetsAndShowProgressHUD;
@end
