//
//  TimelineViewController.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/31/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "TimelineViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import <MBProgressHUD.h>
#import "HBMenuController.h"

@interface TimelineViewController ()
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) TweetTableViewController* tableViewController;
@property (weak, nonatomic) IBOutlet UIView *tableOutlet;
@property (copy, nonatomic) void (^dataLoadingBlockWithSuccessFailure)(void (^success)(NSArray *), void (^failure)(NSError *));
@end

extern HBMenuController* menuController;

@implementation TimelineViewController

- (id) initWithDataLoadingBlockWithSuccessFailure:(void (^)(void (^success)(NSArray *), void (^failure)(NSError *))) block; {
  self = [super init];
  if (self) {
    self.tableViewController = [[TweetTableViewController alloc] init];
    self.tableViewController.delegate = self;
    self.tweets = [[NSMutableArray alloc] init];
    self.dataLoadingBlockWithSuccessFailure = block;
    [self refetchTweetsAndShowProgressHUD];
    
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UITableViewController *tableViewController = [[UITableViewController alloc] init];
  tableViewController.tableView = self.tableViewController.tableView;
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(refetchTweetsViaRefreshControl) forControlEvents:UIControlEventValueChanged];
  tableViewController.refreshControl = self.refreshControl;
  [self.tableOutlet addSubview:self.tableViewController.view];
  
  self.navigationItem.leftBarButtonItem.enabled = NO;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweet_image.png"] style:UIBarButtonItemStylePlain target:self action:@selector(composeNewTweet)];
  
  self.title = @"home";
  
}

- (void) composeNewTweet {
  ComposeTweetViewController *composeViewController = [[ComposeTweetViewController alloc] initWithTweetText:@"" replyToTweetId:nil];
  composeViewController.delegate = self;
  UINavigationController *wrapperNavController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
  [self presentViewController:wrapperNavController animated:YES completion: nil];
}


- (void) viewWillAppear:(BOOL)animated {
  self.navigationController.navigationBarHidden=NO;
  [super viewWillAppear:animated];
  [self.tableViewController.tableView reloadData];
  
}

- (void)SignOut {
  [User removeCurrentUser];
}

- (void) setTweets:(NSArray *)tweets {
  _tweets = [tweets mutableCopy];
}

- (void) refetchTweetsAndShowProgressHUD {
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  self.dataLoadingBlockWithSuccessFailure(^(NSArray *tweets) {
    self.tweets = [tweets mutableCopy];
    [self.tableViewController.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
  }, ^(NSError *error) {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
  });
}

- (void) refetchTweetsViaRefreshControl {
  self.dataLoadingBlockWithSuccessFailure(^(NSArray *tweets) {
    self.tweets = [tweets mutableCopy];
    [self.tableViewController.tableView reloadData];
    [self.refreshControl endRefreshing];
  }, ^(NSError *error) {
    [self.refreshControl endRefreshing];
  });
}

- (void)newTweet {
}

- (void)sendTweet:(Tweet *)tweet {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelNewTweet {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
