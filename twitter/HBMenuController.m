//
//  HBMenuViewController.m
//  twitter
//
//  Created by Ali YAZDAN PANAH on 11/05/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import "HBMenuController.h"
#import "TimelineViewController.h"

@implementation UIViewController (HBMenuItem)
- (void)setHBMenuController:(HBMenuController *)HBMenuController {}
- (HBMenuController *)HBMenuController {return nil;}
@end

static CGFloat const kMinTrigger = 20.0f;
static CGFloat const kMaxAnimationTime = 0.3;
static CGFloat const kMenuItemHeight = 65.0f;
static CGFloat const kOffsetFactor = .25f;

@interface HBMenuController ()
@property (nonatomic, assign) BOOL isMenuRevealed;
@property (nonatomic, strong) UIViewController* activeViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HBMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.kOffsetFactor = kOffsetFactor;
    self.kMinTrigger = kMinTrigger;
    self.kMaxAnimationTime = kMaxAnimationTime;
    self.backGroundColor = [UIColor colorWithRed:85.0/255.0 green:172.0/255.0 blue:238.0/255.0 alpha:1.0];
    self.defaultTextColor = [UIColor darkGrayColor];
    self.selectionColor = [UIColor clearColor];
  }
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = self.backGroundColor;
  self.tableView.scrollEnabled = NO;
  [self.tableView setSeparatorColor:[UIColor whiteColor]];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableCell"];
  
  UIView *extraSpace = [[UIView alloc] initWithFrame:CGRectZero];
  extraSpace.backgroundColor = [UIColor clearColor];
  [self.tableView setTableFooterView:extraSpace];
  
  [self reloadMenu];
}


- (void)setDelegate:(id<HBMenuDelegate>)delegate {
  _delegate = delegate;
  if (delegate) {
    self.activeViewController = [delegate viewControllerAtIndex:0 HBMenuController:self];
    [self reloadMenu];
  }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell* thisTableViewCell = nil;
  
  if ([self.delegate respondsToSelector:@selector(cellForMenuItemAtIndex:HBMenuController:)]) {
    thisTableViewCell = [self.delegate cellForMenuItemAtIndex:indexPath.row HBMenuController:self];
  }
  
  if (thisTableViewCell == nil && [self.delegate respondsToSelector:@selector(viewControllerAtIndex:HBMenuController:)]) {
    thisTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    thisTableViewCell.backgroundColor = self.backGroundColor;
    if (thisTableViewCell.selectedBackgroundView.backgroundColor != self.selectionColor) {
      thisTableViewCell.selectedBackgroundView = [[UIView alloc] initWithFrame:thisTableViewCell.bounds];
      thisTableViewCell.selectedBackgroundView.backgroundColor = self.selectionColor;
    }
    thisTableViewCell.textLabel.textColor = self.defaultTextColor;
    thisTableViewCell.textLabel.text = [self.delegate viewControllerAtIndex:indexPath.row HBMenuController:self].title;
  }
  return thisTableViewCell;
}

- (void) setActiveViewController:(UIViewController *)activeViewController {
  CGRect frame;
  if (_activeViewController) {
    frame = _activeViewController.view.frame;
  } else {
    frame = self.view.frame;
  }
  _activeViewController = activeViewController;
  [self updateActiveViewWithFrame:frame];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.delegate) {
    return [self.delegate numberOfItemsInMenu:self];
  }
  
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.delegate respondsToSelector:@selector(heightForItemAtIndex:HBMenuController:)]) {
    return [self.delegate heightForItemAtIndex:indexPath.row HBMenuController:self];
  }
  return kMenuItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIViewController *selectedViewController = [self.delegate viewControllerAtIndex:indexPath.row HBMenuController:self];
  
  if (selectedViewController) {
    self.activeViewController = selectedViewController;
    [self closeHBMenuWithDuration:self.kMaxAnimationTime];
  }
  
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  [self.delegate didSelectItemAtIndex:indexPath.row HBMenuController:self];
}

- (void)reloadMenu {
  for (NSInteger i = 0; i < [self.delegate numberOfItemsInMenu:self]; ++i) {
    UIViewController *menuItem = [self.delegate viewControllerAtIndex:i HBMenuController:self];
    menuItem.HBMenuController = self;
  }
  [self.tableView reloadData];
  [self updateActiveViewWithFrame:self.view.frame];
}

- (void) updateActiveViewWithFrame:(CGRect)frame; {
  if (self.activeViewController && ![self.activeViewController.view isDescendantOfView:self.view]) {
    for (UIView* view in [self.view subviews]) {
      if (view != self.tableView) {
        [view removeFromSuperview];
      }
    }
    self.activeViewController.view.frame = frame;
    [self.view addSubview:self.activeViewController.view];
  }
}


- (IBAction)panAction:(UIPanGestureRecognizer *)recognizer {
  static CGPoint gestureStartingLocation;
  static CGPoint activeViewStartingCenter;
  
  UIView *activeView = self.activeViewController.view;
  CGPoint location =  [recognizer translationInView:self.view];
  
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    gestureStartingLocation = location;
    activeViewStartingCenter = activeView.center;
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat deltaX = location.x - gestureStartingLocation.x;
    if (activeViewStartingCenter.x + deltaX > self.view.center.x) {
      activeView.center = CGPointMake(activeViewStartingCenter.x + deltaX, activeView.center.y);
    }
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    
    CGFloat deltaX = location.x - gestureStartingLocation.x;
    CGPoint velocity = [recognizer velocityInView:self.view];
    CGFloat duration = MIN(self.view.frame.size.width / ABS(velocity.x), self.kMaxAnimationTime);
    BOOL sameDirection = (velocity.x < 0 && deltaX < 0) || (velocity.x > 0 && deltaX > 0);
    
    if (sameDirection && ABS(deltaX) > self.kMinTrigger) {
      if (velocity.x > 0) {
        [self openHBMenuWithDuration:duration];
      } else {
        [self closeHBMenuWithDuration:duration];
      }
    } else {
      if (self.isMenuRevealed) {
        [self openHBMenuWithDuration:duration];
      } else {
        [self closeHBMenuWithDuration:duration];
      }
    }
  }
}

- (void)animateActiveViewWithDuration:(NSTimeInterval)duration finalPoint:(CGPoint)finalPoint isMenuRevealed:(BOOL)isMenuRevealed {
  [UIView animateWithDuration:duration animations:^{
    self.activeViewController.view.center = finalPoint;
  } completion:^(BOOL finished){
    self.isMenuRevealed = isMenuRevealed;
  }];
}

- (void)openHBMenuWithDuration:(NSTimeInterval)duration {
  CGFloat snapCenterX = (1 + 2 * self.kOffsetFactor) * self.view.center.x;
  CGPoint finalPoint = CGPointMake(snapCenterX, self.activeViewController.view.center.y);
  [self animateActiveViewWithDuration:duration finalPoint:finalPoint isMenuRevealed:YES];
  if (self.activeViewController) {
  }
}

- (void)closeHBMenuWithDuration:(NSTimeInterval)duration {
  CGPoint finalPoint = CGPointMake(self.view.center.x, self.activeViewController.view.center.y);
  [self animateActiveViewWithDuration:duration finalPoint:finalPoint isMenuRevealed:NO];
  if (self.activeViewController) {
  }
}

@end


