//
//  QuadCurveMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>

#import "QuadCurveBlowupAnimation.h"
#import "QuadCurveShrinkAnimation.h"
#import "QuadCurveItemExpandAnimation.h"
#import "QuadCurveItemClosedAnimation.h"

#pragma mark - Constants

static CGFloat const kQuadCurveMenuDefaultNearRadius = 110.0f;
static CGFloat const kQuadCurveMenuDefaultEndRadius = 120.0f;
static CGFloat const kQuadCurveMenuDefaultFarRadius = 140.0f;
static CGFloat const kQuadCurveMenuDefaultStartPointX = 160.0;
static CGFloat const kQuadCurveMenuDefaultStartPointY = 240.0;
static CGFloat const kQuadCurveMenuDefaultTimeOffset = 0.036f;
static CGFloat const kQuadCurveMenuDefaultRotateAngle = 0.0;
static CGFloat const kQuadCurveMenuDefaultMenuWholeAngle = M_PI * 2;

static int const kQuadCurveMenuItemStartingTag = 1000;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

#pragma mark - Private Interface

@interface QuadCurveMenu () {
    int _flag;
    NSTimer *_timer;
    QuadCurveMenuItem *mainMenuButton;
    
    id<QuadCurveMenuDelegate> _delegate;
    id<QuadCurveDataSourceDelegate> dataSource_;
    
    BOOL delegateHasDidBeginTouchingMenu;
    BOOL delegateHasDidEndTouchingMenu;
    BOOL delegateHasShouldExpand;
    BOOL delegateHasShouldClose;
    BOOL delegateHasWillExpand;
    BOOL delegateHasDidExpand;
    BOOL delegateHasWillClose;
    BOOL delegateHasDidClose;
    BOOL delegateHasDidBeginTouching;
    BOOL delegateHasDidEndTouching;
    
}

- (void)_expand;
- (void)_close;
- (void)_setMenu;

@end

#pragma mark - Implementation

@implementation QuadCurveMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint;

@synthesize selectedAnimation;
@synthesize unselectedanimation;
@synthesize expandItemAnimation;
@synthesize closeItemAnimation;

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
        
        [self setSelectedAnimation:[[QuadCurveBlowupAnimation alloc] init]];
        [self setUnselectedanimation:[[QuadCurveShrinkAnimation alloc] init]];        
        
        [self setExpandItemAnimation:[[QuadCurveItemExpandAnimation alloc] init]];
        [self setCloseItemAnimation:[[QuadCurveItemClosedAnimation alloc] init]];
        
        [self setDataSource:dataSource];
        
        
        mainMenuButton = [[QuadCurveMenuItem alloc] initWithImage:nil
                                       highlightedImage:nil 
                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"] 
                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
        mainMenuButton.delegate = self;
        
        mainMenuButton.center = CGPointMake(kQuadCurveMenuDefaultStartPointX, kQuadCurveMenuDefaultStartPointY);
        
        [self addSubview:mainMenuButton];
        
    }
    return self;
}

#pragma mark - Deallocation

- (void)dealloc {
    [selectedAnimation release];
    [unselectedanimation release];
    [expandItemAnimation release];
    [closeItemAnimation release];
    [mainMenuButton release];
    [super dealloc];
}

#pragma mark - Event Delegate

- (void)setDelegate:(id<QuadCurveMenuDelegate>)delegate {
    
    if (delegate == nil) { return; }
    
    delegateHasDidBeginTouchingMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didBeginTouchingMenu:)];
    delegateHasDidEndTouchingMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didEndTouchingMenu:)];
    delegateHasShouldExpand = [delegate respondsToSelector:@selector(quadCurveMenuShouldExpand:)];
    delegateHasShouldClose = [delegate respondsToSelector:@selector(quadCurveMenuShouldClose:)];
    delegateHasWillExpand = [delegate respondsToSelector:@selector(quadCurveMenuWillExpand:)];
    delegateHasDidExpand = [delegate respondsToSelector:@selector(quadCurveMenuDidExpand:)];
    delegateHasWillClose = [delegate respondsToSelector:@selector(quadCurveMenuWillClose:)];
    delegateHasDidClose = [delegate respondsToSelector:@selector(quadCurveMenuDidClose:)];
    delegateHasDidBeginTouching = [delegate respondsToSelector:@selector(quadCurveMenu:didBeginTouching:)];
    delegateHasDidEndTouching = [delegate respondsToSelector:@selector(quadCurveMenu:didEndTouching:)];
    
    [self willChangeValueForKey:@"delegate"];
    _delegate = delegate;
    [self didChangeValueForKey:@"delegate"];
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


#pragma mark - images

- (void)setContentImage:(UIImage *)contentImage {
	mainMenuButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return mainMenuButton.contentImageView.image;
}


- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	mainMenuButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
    return mainMenuButton.contentImageView.highlightedImage;
}
                               
#pragma mark - UIView's methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding) {
        return YES;
    } else {
        CGRect buttonFrame = CGRectOffset(mainMenuButton.contentImageView.frame, mainMenuButton.center.x, mainMenuButton.center.y);
        BOOL touchResult = CGRectContainsPoint(buttonFrame, point);
        return touchResult;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.expanding = !self.isExpanding;
}

#pragma mark - QuadCurveMenuItemEventDelegate Adherence

- (void)mainMenuItemTouchesBegan {
    
    if (delegateHasDidBeginTouchingMenu) {
        [[self delegate] quadCurveMenu:self didBeginTouchingMenu:mainMenuButton];
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
    
}

- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item {
    
    if (item == mainMenuButton) {
        [self mainMenuItemTouchesBegan];
    } else {
        if (delegateHasDidBeginTouching) {
            [[self delegate] quadCurveMenu:self didBeginTouching:item];
        }
    }
}

- (void)animateMenuItems:(NSArray *)items withAnimation:(id<QuadCurveAnimation>)animation {
    for (QuadCurveMenuItem *item in items) {
        CAAnimationGroup *itemAnimation = [animation animateItem:item];
        [item.layer addAnimation:itemAnimation forKey:[animation animationName]];
        item.center = item.startPoint;
    }
}

- (void)rotateMainMenuItemClockwise:(BOOL)animateClockwise {
 
    float angle = animateClockwise ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        mainMenuButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
}

- (void)menuItemTouchesEnd:(QuadCurveMenuItem *)item {

    [self animateMenuItems:[NSArray arrayWithObject:item] withAnimation:[self selectedAnimation]];

    NSPredicate *otherItems = [NSPredicate predicateWithFormat:@"tag BETWEEN { %d, %d } AND tag != %d",
                               kQuadCurveMenuItemStartingTag,
                               (kQuadCurveMenuItemStartingTag + [[self dataSource] numberOfMenuItems]),
                               [item tag]];

    NSArray *otherMenuItems = [[self subviews] filteredArrayUsingPredicate:otherItems];
    
    [self animateMenuItems:otherMenuItems withAnimation:[self unselectedanimation]];
    
    _expanding = NO;

    [self rotateMainMenuItemClockwise:[self isExpanding]];
    
    if (delegateHasDidEndTouching) {
        [[self delegate] quadCurveMenu:self didEndTouching:item];
    }
}

- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item {
    
    if (item == mainMenuButton) {
        if (delegateHasDidEndTouchingMenu) {
            [[self delegate] quadCurveMenu:self didEndTouchingMenu:mainMenuButton];
        }
    } else {
        [self menuItemTouchesEnd:item];
    }
    
}

#pragma mark

- (void)_setMenu {
    
	int count = [[self dataSource] numberOfMenuItems];
    
    for (int i = 0; i < count; i ++) {
        
        QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:(kQuadCurveMenuItemStartingTag + i)];
        
        if (item) { continue; }
        
        item = [[self dataSource] menuItemAtIndex:i];
        
        item.tag = kQuadCurveMenuItemStartingTag + i;
        item.startPoint = startPoint;
        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);  
        item.center = item.startPoint;
        item.delegate = self;
		[self insertSubview:item belowSubview:mainMenuButton];
    }
}

- (BOOL)isExpanding {
    return _expanding;
}


- (void)performMainMenuAnimationWithSelectector:(SEL)animSelector andFlag:(int)flag {
    
    if (_timer) { return; }
    _flag = flag;
    
    // Adding timer to runloop to make sure UI event won't block the timer from firing
    _timer = [[NSTimer timerWithTimeInterval:timeOffset 
                                      target:self 
                                    selector:animSelector 
                                    userInfo:nil 
                                     repeats:YES] retain];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

- (void)performExpandMenu {
    
    if (delegateHasWillExpand) {
        [[self delegate] quadCurveMenuWillExpand:self];
    }
    
    [self _setMenu];
    
    [self performMainMenuAnimationWithSelectector:@selector(_expand) andFlag:0];
}

- (void)performCloseMenu {
    if (delegateHasWillClose) {
        [[self delegate] quadCurveMenuWillClose:self];
    }
    [self performMainMenuAnimationWithSelectector:@selector(_close) 
                                          andFlag:[self.dataSource numberOfMenuItems] - 1];
}

- (void)setExpanding:(BOOL)expanding {
    [self willChangeValueForKey:@"expanding"];
    _expanding = expanding;
    
    [self rotateMainMenuItemClockwise:[self isExpanding]];
    
	if ([self isExpanding]) {
        [self performExpandMenu];
	} else {
        [self performCloseMenu];
    }
    
    [self didChangeValueForKey:@"expanding"];
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
    
    int tag = kQuadCurveMenuItemStartingTag + _flag;
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAAnimationGroup *animationgroup = [[self expandItemAnimation] animateItem:item];
    [item.layer addAnimation:animationgroup forKey:[[self expandItemAnimation] animationName]];
    
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
    
    int tag = kQuadCurveMenuItemStartingTag + _flag;
     QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAAnimationGroup *animationgroup = [[self closeItemAnimation] animateItem:item];
    [item.layer addAnimation:animationgroup forKey:[[self closeItemAnimation] animationName]];
    
    item.center = item.startPoint;
    _flag --;
    
}

@end
