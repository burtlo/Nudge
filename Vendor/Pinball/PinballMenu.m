//
//  PinballMenu.m
//  Nudge
//
//  Created by Franklin Webber on 3/18/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "PinballMenu.h"
#import <QuartzCore/QuartzCore.h>

@implementation PinballMenu

@synthesize delegate;
@synthesize dataSource;


- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item {
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:2 * M_PI], nil];
    rotateAnimation.duration = 2.0f;
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 2.0f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 2.0f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return animationgroup;
}

- (void)animateInFromLeft {
    
    for (int x = 0; x < 10; x++) {
    
        QuadCurveMenuItem *item = [[self dataSource] itemAtIndex:x];
        
        item.delegate = self;
        
        float startX = -1 * (x + 1) * item.image.size.width;
        float endX = self.bounds.size.width + -1 * (x + 1) * item.image.size.width + item.image.size.width/2;

        if (endX < 0) { return; }
        
        [self addSubview:item];
        
        CGPoint startPoint = CGPointMake(startX, item.image.size.height);
        CGPoint endPoint = CGPointMake(endX, item.image.size.height);
        
        
        item.startPoint = startPoint;
        item.center = item.startPoint;
        item.endPoint = endPoint;
        
        CAAnimationGroup *animation = [self animationForItem:item];
        [item.layer addAnimation:animation forKey:@"rolling-right"];
        item.center = item.endPoint;
    }
    
}

#pragma mark - QuadCurveMenuItem Adherence

- (void)quadCurveMenuItemTapped:(QuadCurveMenuItem *)item {
    NSLog(@"tapped");
}

- (void)quadCurveMenuItemLongPressed:(QuadCurveMenuItem *)item {
    NSLog(@"pressed");
}

@end
