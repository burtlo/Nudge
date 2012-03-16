//
//  QuadCurveAnimation.h
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol QuadCurveAnimation <NSObject>

+ (CAAnimationGroup *)animationAtPoint:(CGPoint)point;

@end
