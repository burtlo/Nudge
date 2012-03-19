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
#import "QuadCurveItemCloseAnimation.h"

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
    QuadCurveMenuItem *mainMenuButton;
    
    id<QuadCurveMenuDelegate> _delegate;
    id<QuadCurveDataSourceDelegate> dataSource_;
    
    BOOL delegateHasDidTapMainMenu;
    BOOL delegateHasDidLongPressMainMenu;
    BOOL delegateHasShouldExpand;
    BOOL delegateHasShouldClose;
    BOOL delegateHasWillExpand;
    BOOL delegateHasDidExpand;
    BOOL delegateHasWillClose;
    BOOL delegateHasDidClose;
    BOOL delegateHasDidTapMenuItem;
    BOOL delegateHasDidLongPressMenuItem;
    
}

- (void)animateMenuItemToEndPoint:(QuadCurveMenuItem *)item;
- (void)animateItemToStartPoint:(QuadCurveMenuItem *)item;
- (void)performExpandMenu;
- (void)performCloseMenu;
- (void)addMenuItemsToView;

- (void)menuItemTapped:(QuadCurveMenuItem *)item;
- (void)mainMenuItemTapped;

- (void)menuItemLongPressed:(QuadCurveMenuItem *)item;
- (void)mainMenuItemLongPressed;

@end

#pragma mark - Implementation

@implementation QuadCurveMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint;

@synthesize selectedAnimation;
@synthesize unselectedanimation;
@synthesize expandItemAnimation;
@synthesize closeItemAnimation;

@synthesize expanding = _expanding;
@dynamic inProgress;

@synthesize delegate = _delegate;
@synthesize dataSource = dataSource_;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame dataSource:(id<QuadCurveDataSourceDelegate>)dataSource {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		
        self.nearRadius = kQuadCurveMenuDefaultNearRadius;
        self.endRadius = kQuadCurveMenuDefaultEndRadius;
        self.farRadius = kQuadCurveMenuDefaultFarRadius;
        self.timeOffset = kQuadCurveMenuDefaultTimeOffset;
        self.rotateAngle = kQuadCurveMenuDefaultRotateAngle;
		self.menuWholeAngle = kQuadCurveMenuDefaultMenuWholeAngle;
        self.startPoint = CGPointMake(kQuadCurveMenuDefaultStartPointX, kQuadCurveMenuDefaultStartPointY);
        
        self.selectedAnimation = [[[QuadCurveBlowupAnimation alloc] init] autorelease];
        self.unselectedanimation = [[[QuadCurveShrinkAnimation alloc] init] autorelease];
        
        self.expandItemAnimation = [[[QuadCurveItemExpandAnimation alloc] init] autorelease];
        self.closeItemAnimation = [[[QuadCurveItemCloseAnimation alloc] init] autorelease];
        
        self.dataSource = dataSource;
        
        mainMenuButton = [[QuadCurveMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon-plus.png"] 
                                                 highlightedImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
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

    [self willChangeValueForKey:@"delegate"];

    _delegate = delegate;

    delegateHasDidTapMainMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didTapMenu:)];
    delegateHasDidLongPressMainMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didLongPressMenu:)];
    
    delegateHasDidTapMenuItem = [delegate respondsToSelector:@selector(quadCurveMenu:didTapMenuItem:)];
    delegateHasDidLongPressMenuItem = [delegate respondsToSelector:@selector(quadCurveMenu:didLongPressMenu:)];
    
    delegateHasShouldExpand = [delegate respondsToSelector:@selector(quadCurveMenuShouldExpand:)];
    delegateHasShouldClose = [delegate respondsToSelector:@selector(quadCurveMenuShouldClose:)];
    delegateHasWillExpand = [delegate respondsToSelector:@selector(quadCurveMenuWillExpand:)];
    delegateHasDidExpand = [delegate respondsToSelector:@selector(quadCurveMenuDidExpand:)];
    delegateHasWillClose = [delegate respondsToSelector:@selector(quadCurveMenuWillClose:)];
    delegateHasDidClose = [delegate respondsToSelector:@selector(quadCurveMenuDidClose:)];
    
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

#pragma mark - Progress

- (void)setInProgress:(BOOL)inProgress {
    mainMenuButton.inProgress = inProgress;
}

- (BOOL)inProgress {
    return mainMenuButton.inProgress;
}

#pragma mark - images

- (void)setContentImage:(UIImage *)contentImage {
    [self willChangeValueForKey:@"contentImage"];
	mainMenuButton.image = contentImage;
    [self didChangeValueForKey:@"contentImage"];
}

- (UIImage*)contentImage {
    return mainMenuButton.image;
}


- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
    [self willChangeValueForKey:@"highlightedContentImage"];
	mainMenuButton.highlightedImage = highlightedContentImage;
    [self didChangeValueForKey:@"highlightedContentImage"];
}

- (UIImage*)highlightedContentImage {
    return mainMenuButton.highlightedImage;
}

#pragma mark - QuadCurveMenuItemEventDelegate Adherence


#pragma mark Tap Event

- (void)quadCurveMenuItemTapped:(QuadCurveMenuItem *)item {
    
    if (item == mainMenuButton) {
        [self mainMenuItemTapped];
    } else {
        [self menuItemTapped:item];
    }
}

- (void)mainMenuItemTapped {
    
    if (delegateHasDidTapMainMenu) {
        [[self delegate] quadCurveMenu:self didTapMenu:mainMenuButton];
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

- (void)menuItemTapped:(QuadCurveMenuItem *)item {

    if (delegateHasDidTapMenuItem) {
        [[self delegate] quadCurveMenu:self didTapMenuItem:item];
    }

    [self animateMenuItems:[NSArray arrayWithObject:item] withAnimation:[self selectedAnimation]];
    
    NSPredicate *otherItems = [NSPredicate predicateWithFormat:@"tag != %d",[item tag]];
    
    NSArray *otherMenuItems = [[self allMenuItemsBeingDisplayed] filteredArrayUsingPredicate:otherItems];
    
    [self animateMenuItems:otherMenuItems withAnimation:[self unselectedanimation]];
    
    _expanding = NO;
    
    [self rotateMainMenuItemClockwise:[self isExpanding]];
    
}

#pragma mark Long Press Event

- (void)quadCurveMenuItemLongPressed:(QuadCurveMenuItem *)item {
    
    if (item == mainMenuButton) {
        [self mainMenuItemLongPressed];
    } else {
        [self menuItemLongPressed:item];
    }

}

- (void)mainMenuItemLongPressed {
    
    if (delegateHasDidLongPressMainMenu) {
        [[self delegate] quadCurveMenu:self didLongPressMenu:mainMenuButton];
    }
    
}

- (void)menuItemLongPressed:(QuadCurveMenuItem *)item {
    
    if (delegateHasDidLongPressMenuItem) {
        [[self delegate] quadCurveMenu:self didLongPressMenuItem:item];
    }
    
}

#pragma mark - Selection Animations

- (void)animateMenuItems:(NSArray *)items withAnimation:(id<QuadCurveAnimation>)animation {
    for (QuadCurveMenuItem *item in items) {
        CAAnimationGroup *itemAnimation = [animation animationForItem:item];
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

- (NSArray *)allMenuItemsBeingDisplayed {
    
    NSPredicate *allMenuItemsPredicate = [NSPredicate predicateWithFormat:@"tag BETWEEN { %d, %d }",
                                          kQuadCurveMenuItemStartingTag,
                                          (kQuadCurveMenuItemStartingTag + [[self dataSource] numberOfMenuItems])];
    
    return [[self subviews] filteredArrayUsingPredicate:allMenuItemsPredicate];
}

#pragma mark - Expanding / Closing the Menu

- (BOOL)isExpanding {
    return _expanding;
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

#pragma mark - QuadCurveMenuItemReciver Adherence

- (BOOL)shouldAcceptMenuItem:(QuadCurveMenuItem *)item {
    return YES;
}

- (void)acceptMenuItem:(QuadCurveMenuItem *)item {
    [[self dataSource] addDataItem:[item dataObject]];
}

#pragma mark - Animate MenuItems Expanded

- (void)performExpandMenu {
    
    if (delegateHasWillExpand) {
        [[self delegate] quadCurveMenuWillExpand:self];
    }
    
    [self addMenuItemsToView];
 
    NSArray *itemToBeAnimated = [self allMenuItemsBeingDisplayed];
    
    for (int x = 0; x < [itemToBeAnimated count]; x++) {
        QuadCurveMenuItem *item = [itemToBeAnimated objectAtIndex:x];
        [self performSelector:@selector(animateMenuItemToEndPoint:) withObject:item afterDelay:timeOffset * x];
    }
    
    if (delegateHasDidExpand) {
        [[self delegate] quadCurveMenuDidExpand:self];
    }
    
}

- (void)addMenuItemsToView {
    
	int count = [[self dataSource] numberOfMenuItems];
    
    for (int i = 0; i < count; i ++) {
        
        QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:(kQuadCurveMenuItemStartingTag + i)];
        
        if (item == nil) { 
            item = [[self dataSource] menuItemAtIndex:i];
        }
        
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

- (void)animateMenuItemToEndPoint:(QuadCurveMenuItem *)item {
    CAAnimationGroup *expandAnimation = [[self expandItemAnimation] animationForItem:item];
    [item.layer addAnimation:expandAnimation forKey:[[self expandItemAnimation] animationName]];
    item.center = item.endPoint;
}

#pragma mark - Animate MenuItems Closed

- (void)performCloseMenu {
    
    if (delegateHasWillClose) {
        [[self delegate] quadCurveMenuWillClose:self];
    }
    
    NSArray *itemToBeAnimated = [self allMenuItemsBeingDisplayed];
    
    for (int x = 0; x < [itemToBeAnimated count]; x++) {
        QuadCurveMenuItem *item = [itemToBeAnimated objectAtIndex:x];
        [self performSelector:@selector(animateItemToStartPoint:) withObject:item afterDelay:timeOffset * x];
    }

    if (delegateHasDidClose) {
        [[self delegate] quadCurveMenuDidClose:self];
    }

}

- (void)animateItemToStartPoint:(QuadCurveMenuItem *)item {
    CAAnimationGroup *closeAnimation = [[self closeItemAnimation] animationForItem:item];
    [item.layer addAnimation:closeAnimation forKey:[[self closeItemAnimation] animationName]];
    item.center = item.startPoint;
}

@end
