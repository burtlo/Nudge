//
//  QuadCurveMenuItem.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "AGMedallionView.h"

@protocol QuadCurveMenuItemEventDelegate;


@interface QuadCurveMenuItem : UIControl

@property (nonatomic, retain, readonly) AGMedallionView *contentImageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *highlightedImage;

@property (nonatomic, assign) BOOL inProgress;
//@property (nonatomic, assign) BOOL ignoreTouches;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;

@property (nonatomic, assign) id<QuadCurveMenuItemEventDelegate> delegate;

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

@end




@protocol QuadCurveMenuItemEventDelegate <NSObject>

@optional

- (void)quadCurveMenuItemLongPressed:(QuadCurveMenuItem *)item;
- (void)quadCurveMenuItemTapped:(QuadCurveMenuItem *)item;
- (void)quadCurveMenuItemDragged:(QuadCurveMenuItem *)item withPanGesture:(UIPanGestureRecognizer *)gesture;

@end