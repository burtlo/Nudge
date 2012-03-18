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
@synthesize delegate  = delegate_;

@synthesize progressTimer = progressTimer_;
@synthesize inProgress = inProgress_;


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
    }
    
    [self didChangeValueForKey:@"inProgress"];
        
}

#pragma mark - UIView Overridden Methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = contentImageView_.image.size.width;
    float height = contentImageView_.image.size.height;
    contentImageView_.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect buttonFrame = self.contentImageView.frame;
    BOOL touchResult = CGRectContainsPoint(buttonFrame, point);
    return touchResult;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

#pragma mark - Status Methods

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [contentImageView_ setHighlighted:highlighted];
}


@end
