//
//  AppDelegate.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 10/27/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "AppDelegate.h"
#import "SignInViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TimelineViewController.h"
#import "ComposeTweetViewController.h"
#import "ProfileViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSArray* viewControllersInMenu;
@property (nonatomic, strong) UIViewController* signInViewController;
@property (nonatomic, strong) UIViewController* timelineViewController;
@property (nonatomic, strong) ProfileViewController* myProfileViewController;
@property (nonatomic, strong) HBMenuController* menuController;
@property (nonatomic, strong) UITableViewCell* extraCell;
@property (nonatomic, strong) UITableViewCell* signOutButton;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [self setupNotifications];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.signInViewController = [[SignInViewController alloc] init];
  
  //populate and setup HBMenuController
  self.viewControllersInMenu = @[self.timelineViewController, [[UINavigationController alloc] initWithRootViewController:self.myProfileViewController]];
  
  self.menuController = [[HBMenuController alloc] init];
  self.menuController.delegate = self;
  //check to see if user is logged in
  User *user  = [User currentUser];
  if(user) {
    self.window.rootViewController = self.menuController;
  }
  else {
    self.window.rootViewController = self.signInViewController;
  }
  
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (NSInteger)numberOfItemsInMenu:(HBMenuController *)HBMenuController {
  return self.viewControllersInMenu.count + 2;
}


- (void)setupNotifications {
  [[NSNotificationCenter defaultCenter] addObserverForName:kCurrentUserSetNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
    self.window.rootViewController = self.timelineViewController;
  }];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:kCurrentUserRemovedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
    self.window.rootViewController = self.signInViewController ;
  }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
  
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kTwitterClientCallbackNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kTwitterClientCallbackURLKey]]];
  
  return YES;
}

- (UIViewController *)timelineViewController {
  if (!_timelineViewController) {
    TimelineViewController*  timelineViewController = [[TimelineViewController alloc] initWithDataLoadingBlockWithSuccessFailure:^(void (^success)(NSArray *), void (^failure)(NSError *)) {
      [[TwitterClient instance] homeTimelineWithSuccess:success failure:failure];
    }];
    timelineViewController.title = @"Home";
    [[NSNotificationCenter defaultCenter] addObserverForName:kNewTweetPostedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      Tweet* tweet = notification.userInfo[kNewTweetPostedNotificationKey];
      [timelineViewController.tweets insertObject:tweet atIndex:0];
    }];
    _timelineViewController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
  }
  
  return _timelineViewController;
}

- (UIViewController *)myProfileViewController {
  if (!_myProfileViewController) {
    ProfileViewController *myProfileViewController = [[ProfileViewController alloc] initWithUser:[User currentUser]];
    myProfileViewController.title = @"Me";
    myProfileViewController.shouldShowMenuButton = NO;
    _myProfileViewController = myProfileViewController;
  }
  
  return _myProfileViewController;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index HBMenuController:(HBMenuController *)HBMenuController {
  if (index < self.viewControllersInMenu.count) {
    return self.viewControllersInMenu[index];
  }
  
  return nil;
}

- (UITableViewCell *)cellForMenuItemAtIndex:(NSInteger)index HBMenuController:(HBMenuController *)HBMenuController {
  if (index == self.viewControllersInMenu.count) {
    return self.extraCell;
  } else if (index == self.viewControllersInMenu.count + 1) {
    return self.signOutButton;
  }
  return nil;
}

- (void) signOut
{
  [self.menuController closeHBMenuWithDuration:0];
  [User removeCurrentUser];
}

- (UITableViewCell*)signOutButton {
  if (!_signOutButton) {
    _signOutButton = [[UITableViewCell alloc] init];
    _signOutButton.textLabel.text = @"";
    _signOutButton.backgroundColor = self.menuController.backGroundColor;
    _signOutButton.textLabel.textColor = [UIColor redColor];
    _signOutButton.selectedBackgroundView = [[UIView alloc] initWithFrame:_signOutButton.bounds];
    _signOutButton.selectedBackgroundView.backgroundColor = self.menuController.selectionColor;
    _signOutButton.imageView.image =[UIImage imageNamed:@"signout_image.png"];
  }
  return _signOutButton;
}

- (UITableViewCell *)extraCell {
  if (!_extraCell) {
    _extraCell = [[UITableViewCell alloc] init];
    _extraCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _extraCell.backgroundColor = self.menuController.backGroundColor;
  }
  return _extraCell;
}

- (void)didSelectItemAtIndex:(NSInteger)index HBMenuController:(HBMenuController *)HBMenuController {
  UIViewController *selectedController = [self viewControllerAtIndex:index HBMenuController:HBMenuController];
  if ([selectedController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navController = (UINavigationController *) selectedController;
    [navController popToRootViewControllerAnimated:YES];
  } else if (index == self.viewControllersInMenu.count + 1) {
    [HBMenuController closeHBMenuWithDuration:HBMenuController.kMaxAnimationTime];
    [self signOut];
  }
}

@end
