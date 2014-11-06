//
//  ProfileViewController.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 11/05/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.

#import "ProfileViewController.h"
#import <MBProgressHUD.h>
#import "TwitterClient.h"
#import "HBMenuController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ProfileViewController ()
@property (strong, nonatomic) TweetTableViewController* tableViewController;
@property (weak, nonatomic) IBOutlet UIScrollView *generalScrollView;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIView *tableOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation ProfileViewController

- (id)initWithUser:(User *)user {
  self = [super init];
  if (self) {
    self.tableViewController = [[TweetTableViewController alloc] init];
    self.tableViewController.delegate = self;
    self.tweets = [[NSMutableArray alloc] init];
    self.user = user;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweet_image.png"] style:UIBarButtonItemStylePlain target:self action:@selector(newTweet)];
  [self.tableOutlet addSubview:self.tableViewController.view];
  [self refreshView];
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableViewController.tableView reloadData];
}

- (void)setUser:(User *)user {
  _user = user;
  [self refreshView];
  [self refetchTweets];
}

- (void)refreshView {
  [self.profileImage setImageWithURL:self.user.profileImageURL];
  [self.backgroundImage setImageWithURL:self.user.bannerImageURL];
  self.nameLabel.text = self.user.name;
  self.screennameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
  self.tweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.tweetCount];
  self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.followingCount];
  self.followerCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.followerCount];
  [self.tableViewController.tableView reloadData];
}

- (void)refetchTweets {
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
  [[TwitterClient instance] userTimeLine:self.user success:^(NSArray *tweets) {
    self.tweets = [tweets mutableCopy];
    [self.tableViewController.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
  } failure:^(NSError *error) {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
  }];
}

- (void)newTweet {
  ComposeTweetViewController *composeViewController = [[ComposeTweetViewController alloc] initWithTweetText:@"" replyToTweetId:nil];
  composeViewController.delegate = self;
  UINavigationController *wrapperNavController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
  [self presentViewController:wrapperNavController animated:YES completion: nil];
}

- (void)cancelNewTweet {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendTweet:(Tweet *)tweet {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
