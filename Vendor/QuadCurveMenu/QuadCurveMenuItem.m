//
//  QuadCurveMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenuItem.h"

@interface QuadCurveMenuItem () {
   
    BOOL delegateHasLongPressed;
    BOOL delegateHasTapped;
    
}


@property (nonatomic,retain) NSTimer *progressTimer;

- (void)longPressOnMenuItem:(UIGestureRecognizer *)sender;
- (void)singleTapOnMenuItem:(UIGestureRecognizer *)sender;

@end

@implementation QuadCurveMenuItem

@synthesize contentImageView = contentImageView_;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;

@dynamic image;
@dynamic highlightedImage;

@synthesize progressTimer = progressTimer_;
@synthesize inProgress = inProgress_;

@synthesize delegate  = delegate_;

#pragma mark - Initialization

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    
    self = [super init];
    if (self) {
        
        self.userInteractionEnabled = YES;
        contentImageView_ = [[AGMedallionView alloc] init];
        [contentImageView_ setImage:image];
        [contentImageView_ setHighlightedImage:highlightedImage];
        
        [self addSubview:contentImageView_];
     
        
        UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMenuItem:)] autorelease];
        
        [self addGestureRecognizer:longPressGesture];

        UITapGestureRecognizer *singleTapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnMenuItem:)] autorelease];
        
        [self addGestureRecognizer:singleTapGesture];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)dealloc {
    [contentImageView_ release];
    [progressTimer_ invalidate];
    [progressTimer_ release];
    [super dealloc];
}

#pragma mark - Delegate

- (void)setDelegate:(id<QuadCurveMenuItemEventDelegate>)delegate {

    [self willChangeValueForKey:@"delegate"];
    
    delegate_ = delegate;
    
    delegateHasLongPressed = [delegate respondsToSelector:@selector(quadCurveMenuItemLongPressed:)];
    delegateHasTapped = [delegate respondsToSelector:@selector(quadCurveMenuItemTapped:)];
    
    [self didChangeValueForKey:@"delegate"];
    
}

#pragma mark - Gestures

- (void)longPressOnMenuItem:(UILongPressGestureRecognizer *)sender {

    if (delegateHasLongPressed) {
        [delegate_ quadCurveMenuItemLongPressed:self];
    }

}

- (void)singleTapOnMenuItem:(UITapGestureRecognizer *)sender {
    
    if (delegateHasTapped) {
        [delegate_ quadCurveMenuItemTapped:self];
    }
    
}

#pragma mark - In Progress State

- (void)progressChange {
    
    self.contentImageView.progress = self.contentImageView.progress + 0.01f;
    if (self.contentImageView.progress > 1.0) {
        self.contentImageView.progress = 0.01;
    }
    
    
}

- (void)startProgressTimer {
    
    NSTimer *newProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                 target:self 
                                                               selector:@selector(progressChange) 
                                                               userInfo:nil 
                                                                repeats:YES];
    [self setProgressTimer:newProgressTimer];
    
}

- (void)stopProgressTimer {
    [[self progressTimer] invalidate];
}

- (void)setInProgress:(BOOL)inProgress {
    
    [self willChangeValueForKey:@"inProgress"];
    
    inProgress_ = inProgress;
    
    if (inProgress) {
        [self startProgressTimer];
    } else {
        [self stopProgressTimer];
        contentImageView_.progress = 0.0;
    }
    
    [self didChangeValueForKey:@"inProgress"];
        
}

#pragma mark - UIView Overridden Methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = CGRectMake(self.center.x - self.image.size.width/2,self.center.y - self.image.size.height/2,self.image.size.width, self.image.size.height);
    
    float width = self.image.size.width;
    float height = self.image.size.height;

    contentImageView_.frame = CGRectMake(0.0,0.0, width, height);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

#pragma mark - Image and HighlightImage

- (void)setImage:(UIImage *)image {
    [self willChangeValueForKey:@"image"];
    contentImageView_.image = image;
    [self didChangeValueForKey:@"image"];
}

- (UIImage *)image {
    return contentImageView_.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    [self willChangeValueForKey:@"highlightedImage"];
    contentImageView_.highlightedImage = highlightedImage;
    [self didChangeValueForKey:@"highlightedImage"];
}

- (UIImage *)highlightedImage {
    return contentImageView_.highlightedImage;
}

#pragma mark - Status Methods

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [contentImageView_ setHighlighted:highlighted];
}


@end
