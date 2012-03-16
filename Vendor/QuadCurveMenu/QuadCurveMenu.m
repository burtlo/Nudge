//
//  QuadCurveMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kQuadCurveMenuDefaultNearRadius = 110.0f;
static CGFloat const kQuadCurveMenuDefaultEndRadius = 120.0f;
static CGFloat const kQuadCurveMenuDefaultFarRadius = 140.0f;
static CGFloat const kQuadCurveMenuDefaultStartPointX = 160.0;
static CGFloat const kQuadCurveMenuDefaultStartPointY = 240.0;
static CGFloat const kQuadCurveMenuDefaultTimeOffset = 0.036f;
static CGFloat const kQuadCurveMenuDefaultRotateAngle = 0.0;
static CGFloat const kQuadCurveMenuDefaultMenuWholeAngle = M_PI * 2;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface QuadCurveMenu () {
    int _flag;
    NSTimer *_timer;
    QuadCurveMenuItem *_addButton;
    
    id<QuadCurveMenuDelegate> _delegate;
    id<QuadCurveDataSourceDelegate> dataSource_;
    
    BOOL delegateHasDidBeginTouchingMenu;
    BOOL delegateHasDidEndTouchingMenu;
    BOOL delegateHasShouldExpand;
    BOOL delegateHasShouldClose;
    BOOL delegateHasDidBeginTouching;
    BOOL delegateHasDidEndTouching;
    
}

- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;

@end

@implementation QuadCurveMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint;

@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize dataSource = dataSource_;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame dataSource:(id<QuadCurveDataSourceDelegate>)dataSource {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		
		[self setNearRadius:kQuadCurveMenuDefaultNearRadius];
		[self setEndRadius:kQuadCurveMenuDefaultEndRadius];
		[self setFarRadius:kQuadCurveMenuDefaultFarRadius];
		[self setTimeOffset:kQuadCurveMenuDefaultTimeOffset];
		[self setRotateAngle:kQuadCurveMenuDefaultRotateAngle];
		[self setMenuWholeAngle:kQuadCurveMenuDefaultMenuWholeAngle];
        [self setStartPoint:CGPointMake(kQuadCurveMenuDefaultStartPointX, kQuadCurveMenuDefaultStartPointY)];
        
        [self setDataSource:dataSource];
        
        _addButton = [[QuadCurveMenuItem alloc] initWithImage:nil
                                       highlightedImage:nil 
                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"] 
                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
        _addButton.delegate = self;
        
        _addButton.center = CGPointMake(kQuadCurveMenuDefaultStartPointX, kQuadCurveMenuDefaultStartPointY);
        [self addSubview:_addButton];
    }
    return self;
}

#pragma mark - Deallocation

- (void)dealloc
{
    [_addButton release];
    [super dealloc];
}

#pragma mark - Event Delegate

- (void)setDelegate:(id<QuadCurveMenuDelegate>)delegate {
    
    if (delegate == nil) { return; }
    
    delegateHasDidBeginTouchingMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didBeginTouchingMenu:)];
    delegateHasDidEndTouchingMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didEndTouchingMenu:)];
    delegateHasShouldExpand = [delegate respondsToSelector:@selector(quadCurveMenuShouldExpand:)];
    delegateHasShouldClose = [delegate respondsToSelector:@selector(quadCurveMenuShouldClose:)];
    delegateHasDidBeginTouching = [delegate respondsToSelector:@selector(quadCurveMenu:didBeginTouching:)];
    delegateHasDidEndTouching = [delegate respondsToSelector:@selector(quadCurveMenu:didEndTouching:)];
    
    [self willChangeValueForKey:@"delegate"];
    _delegate = delegate;
    [self didChangeValueForKey:@"delegate"];
}


#pragma mark - images

- (void)setImage:(UIImage *)image {
	_addButton.image = image;
}

- (UIImage*)image {
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
	return _addButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
	_addButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return _addButton.contentImageView.image;
}


- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
    return _addButton.contentImageView.highlightedImage;
}


                               
#pragma mark - UIView's methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding) {
        return YES;
    }
    else {
        CGRect buttonFrame = CGRectOffset(_addButton.contentImageView.frame, _addButton.center.x, _addButton.center.y);
        BOOL touchResult = CGRectContainsPoint(buttonFrame, point);
        return touchResult;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.expanding = !self.isExpanding;
}

#pragma mark - QuadCurveMenuItem delegates

- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item {
    
    if (item == _addButton) {
        
        if (delegateHasDidBeginTouchingMenu) {
            [[self delegate] quadCurveMenu:self didBeginTouchingMenu:_addButton];
        }
        
        BOOL willBeExpandingMenu = ![self isExpanding];
        BOOL shouldPerformAction = YES;
        
        if (willBeExpandingMenu && delegateHasShouldExpand) {
            shouldPerformAction = [[self delegate] quadCurveMenuShouldExpand:self];
        }

        if ( ! willBeExpandingMenu && delegateHasShouldClose) {
            shouldPerformAction = [[self delegate] quadCurveMenuShouldClose:self];
        }

        if (shouldPerformAction) {
            [self setExpanding:willBeExpandingMenu];
        }
        
        
    } else {
    
        if (delegateHasDidBeginTouching) {
            [[self delegate] quadCurveMenu:self didBeginTouching:item];
        }
        
    }
}

- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item {
    
    if (item == _addButton) {
        
        if (delegateHasDidEndTouchingMenu) {
            [[self delegate] quadCurveMenu:self didEndTouchingMenu:_addButton];
        }

        return;
    }
    
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [[self dataSource] numberOfMenuItems]; i ++)
    {
        QuadCurveMenuItem *otherItem = [[self dataSource] menuItemAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];

        otherItem.center = otherItem.startPoint;
    }
    _expanding = NO;
    
    // rotate "add" button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if (delegateHasDidEndTouching) {
        [[self delegate] quadCurveMenu:self didEndTouching:item];
    }
}

#pragma mark 

- (void)expandMenu {
    if (![self isExpanding]) {
        [self setExpanding:YES];
    }
}

- (void)closeMenu {
    if ([self isExpanding]) {
        [self setExpanding:NO];
    }
    
}

#pragma mark

- (void)_setMenu {
    
	int count = [[self dataSource] numberOfMenuItems];
    
    for (int i = 0; i < count; i ++) {
        
        QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:(1000 + i)];
        
        if (item) { continue; }
        
        item = [[self dataSource] menuItemAtIndex:i];
        
        item.tag = 1000 + i;
        item.startPoint = startPoint;
        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);  
        item.center = item.startPoint;
        item.delegate = self;
		[self insertSubview:item belowSubview:_addButton];
    }
}

- (BOOL)isExpanding {
    return _expanding;
}

- (void)setExpanding:(BOOL)expanding {
	
	if (expanding) {
		[self _setMenu];
	}
	
    _expanding = expanding;    
    
    // rotate add button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    // expand or close animation
    if (!_timer) 
    {
        _flag = self.isExpanding ? 0 : ([[self dataSource] numberOfMenuItems] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);

        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [[NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES] retain];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - private methods
- (void)_expand {
	
    if (_flag == [[self dataSource] numberOfMenuItems])
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:M_PI],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag ++;
    
}

- (void)_close {
    if (_flag == -1)
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
     QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * 2],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
        
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    _flag --;
    
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p {
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;

    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p {
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end
