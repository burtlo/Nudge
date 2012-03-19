//
//  QuadCurveMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenuItem.h"
#import "QuadCurveAnimation.h"

@protocol QuadCurveMenuItemReceiver <NSObject>

- (BOOL)shouldAcceptMenuItem:(QuadCurveMenuItem *)item;
- (void)acceptMenuItem:(QuadCurveMenuItem *)item;
- (void)menuItem:(QuadCurveMenuItem *)item position:(CGPoint)point;

@end


@protocol QuadCurveMenuDelegate;
@protocol QuadCurveDataSourceDelegate;


@interface QuadCurveMenu : UIView <QuadCurveMenuItemEventDelegate,QuadCurveMenuItemReceiver>

@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, assign) BOOL inProgress;

@property (nonatomic, retain) UIImage *contentImage;
@property (nonatomic, retain) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;

@property (nonatomic, retain) id<QuadCurveAnimation> selectedAnimation;
@property (nonatomic, retain) id<QuadCurveAnimation> unselectedanimation;
@property (nonatomic, retain) id<QuadCurveAnimation> expandItemAnimation;
@property (nonatomic, retain) id<QuadCurveAnimation> closeItemAnimation;

@property (nonatomic, assign) id<QuadCurveMenuDelegate> delegate;
@property (nonatomic, assign) id<QuadCurveDataSourceDelegate> dataSource;

- (id)initWithFrame:(CGRect)frame dataSource:(id<QuadCurveDataSourceDelegate>)dataSource;

- (void)expandMenu;
- (void)closeMenu;
- (void)updateMenu;


@end

@protocol QuadCurveMenuDelegate <NSObject>

@optional


- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem;
- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenu:(QuadCurveMenuItem *)mainMenuItem;

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu;
- (BOOL)quadCurveMenuShouldClose:(QuadCurveMenu *)menu;

- (void)quadCurveMenuWillExpand:(QuadCurveMenu *)menu;
- (void)quadCurveMenuDidExpand:(QuadCurveMenu *)menu;

- (void)quadCurveMenuWillClose:(QuadCurveMenu *)menu;
- (void)quadCurveMenuDidClose:(QuadCurveMenu *)menu;

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenuItem:(QuadCurveMenuItem *)menuItem;
- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenuItem:(QuadCurveMenuItem *)menuItem;

@end

@protocol QuadCurveDataSourceDelegate <NSObject>

- (int)numberOfMenuItems;
- (id)dataObjectAtIndex:(NSInteger)itemIndex;
- (id)menuItemAtIndex:(NSInteger)itemIndex;
- (void)insertDataObject:(id)dataObject atIndex:(int)dataIndex;


@end