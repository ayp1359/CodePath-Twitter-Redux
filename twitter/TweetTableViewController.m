//
//  TweetTableViewController.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/31/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "TweetTableViewController.h"
#import "TwitterClient.h"


@interface TweetTableViewController ()
@property (strong, nonatomic) TweetCell* referenceTweetCell;
@end

@implementation TweetTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  UINib *tweetCellNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
  self.referenceTweetCell = [tweetCellNib instantiateWithOwner:self options:nil][0];
  [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetCell"];
}


#pragma mark - UITableViewDelegate and UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
  Tweet *tweet = self.delegate.tweets[indexPath.row];
  cell.tweet = tweet;
  cell.delegate = self;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.delegate.tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Tweet* tweet = self.delegate.tweets[indexPath.row];
  return [self.referenceTweetCell estimateHeight:tweet];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

@end
