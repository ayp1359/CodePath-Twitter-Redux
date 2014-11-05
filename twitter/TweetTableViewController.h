//
//  TweetTableViewController.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/31/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetCell.h"

@protocol TweetTableViewDelegate <NSObject>
- (UINavigationController*) navigationController;
- (NSArray*) tweets;
@end


@interface TweetTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, TweetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<TweetTableViewDelegate> delegate;
@end

