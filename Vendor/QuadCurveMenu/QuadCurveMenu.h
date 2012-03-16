//
//  QuadCurveMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenuItem.h"

@protocol QuadCurveMenuDelegate;
@protocol QuadCurveDataSourceDelegate;


@interface QuadCurveMenu : UIView <QuadCurveMenuItemEventDelegate>

@property (nonatomic, getter = isExpanding) BOOL expanding;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *highlightedImage;
@property (nonatomic, retain) UIImage *contentImage;
@property (nonatomic, retain) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;

@property (nonatomic, assign) id<QuadCurveMenuDelegate> delegate;
@property (nonatomic, assign) id<QuadCurveDataSourceDelegate> dataSource;

- (id)initWithFrame:(CGRect)frame dataSource:(id<QuadCurveDataSourceDelegate>)dataSource;

- (void)expandMenu;
- (void)closeMenu;

@end

@protocol QuadCurveMenuDelegate <NSObject>

@optional

- (void)quadCurveMenu:(QuadCurveMenu *)menu didBeginTouchingMenu:(QuadCurveMenuItem *)mainMenuItem;
- (void)quadCurveMenu:(QuadCurveMenu *)menu didEndTouchingMenu:(QuadCurveMenuItem *)mainMenuItem;

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu;
- (BOOL)quadCurveMenuShouldClose:(QuadCurveMenu *)menu;

- (void)quadCurveMenu:(QuadCurveMenu *)menu didBeginTouching:(QuadCurveMenuItem *)menuItem;
- (void)quadCurveMenu:(QuadCurveMenu *)menu didEndTouching:(QuadCurveMenuItem *)menuItem;

@end

@protocol QuadCurveDataSourceDelegate <NSObject>

- (int)numberOfMenuItems;
- (id)menuItemAtIndex:(NSInteger)itemIndex;

@end