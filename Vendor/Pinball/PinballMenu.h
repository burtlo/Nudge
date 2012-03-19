//
//  PinballMenu.h
//  Nudge
//
//  Created by Franklin Webber on 3/18/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveMenuItem.h"


@protocol PinballDataSourceDelegate;
@protocol PinballEventDelegate;

@interface PinballMenu : UIView <QuadCurveMenuItemEventDelegate>

@property (nonatomic,strong) id<PinballEventDelegate> delegate;
@property (nonatomic,strong) id<PinballDataSourceDelegate> dataSource;

- (void)animateInFromLeft;

@end


@protocol PinballEventDelegate <NSObject>

@optional
- (void)pinballMenu:(PinballMenu *)menu didTapMenuItem:(id)menuItem;
- (void)pinballMenu:(PinballMenu *)menu didLongPressMenuItem:(id)menuItem;

@end

@protocol PinballDataSourceDelegate <NSObject>

- (int)numberOfItems;
- (QuadCurveMenuItem *)itemAtIndex:(NSInteger)itemIndex;

@end