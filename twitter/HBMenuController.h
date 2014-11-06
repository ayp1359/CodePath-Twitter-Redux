//
//  HBMenuViewController.h
//  twitter
//
//  Created by Ali YAZDAN PANAH on 11/05/14.
//  Copyright (c) 2014 Ali YAZDAN PANAH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBMenuController;

@interface UIViewController (HBMenuItem)
@property (nonatomic, strong) HBMenuController* HBMenuController;
@end

@protocol HBMenuDelegate <NSObject>
@required
- (NSInteger) numberOfItemsInMenu:(HBMenuController*)HBMenuController;
@optional

- (CGFloat) heightForItemAtIndex:(NSInteger)index HBMenuController:(HBMenuController*)HBMenuController;
- (void) didSelectItemAtIndex:(NSInteger)index HBMenuController:(HBMenuController*)HBMenuController;
- (UIViewController*) viewControllerAtIndex:(NSInteger)index HBMenuController:(HBMenuController*)HBMenuController;
- (UITableViewCell*) cellForMenuItemAtIndex:(NSInteger)index HBMenuController:(HBMenuController*)HBMenuController;
@end

@interface HBMenuController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIColor *backGroundColor;
@property (nonatomic, strong) UIColor *selectionColor;
@property (nonatomic, strong) UIColor *defaultTextColor;
@property (nonatomic, strong) id<HBMenuDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isMenuRevealed;
@property (nonatomic, assign) CGFloat kOffsetFactor;
@property (nonatomic, assign) CGFloat kMinTrigger;
@property (nonatomic, assign) CGFloat kMaxAnimationTime;

- (void)openHBMenuWithDuration:(NSTimeInterval)duration;
- (void)closeHBMenuWithDuration:(NSTimeInterval)duration;
- (void)reloadMenu;

@end
