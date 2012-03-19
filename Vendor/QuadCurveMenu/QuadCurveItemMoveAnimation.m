//
//  QuadCurveItemMoveAnimation.m
//  Nudge
//
//  Created by Franklin Webber on 3/19/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveItemMoveAnimation.h"

@implementation QuadCurveItemMoveAnimation

- (NSString *)animationName {
    return @"moveAnimation";
}

- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item {
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * 2], nil];
    rotateAnimation.duration = 0.5f;
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.center.x, item.center.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return animationgroup;
    
}

@end
