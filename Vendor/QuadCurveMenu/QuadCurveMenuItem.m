//
//  QuadCurveMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}

@interface QuadCurveMenuItem () {
    
    AGMedallionView *_contentImageView;
    
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGPoint _nearPoint; // near
    CGPoint _farPoint; // far
    
    id<QuadCurveMenuItemEventDelegate> delegate_;
    
    BOOL delegateHasLongPressed;
    BOOL delegateHasTapped;
    
}

- (void)longPressOnMenuItem:(UIGestureRecognizer *)sender;
- (void)singleTapOnMenuItem:(UIGestureRecognizer *)sender;


@end

@implementation QuadCurveMenuItem

@synthesize contentImageView = _contentImageView;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = delegate_;

#pragma mark - Initialization

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    
    self = [super init];
    if (self) {
        
        self.userInteractionEnabled = YES;
        _contentImageView = [[AGMedallionView alloc] init];
        [_contentImageView setImage:image];
        [_contentImageView setHighlightedImage:highlightedImage];
        
        [self addSubview:_contentImageView];
     
        
        UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMenuItem:)] autorelease];
        
        [self addGestureRecognizer:longPressGesture];

        UITapGestureRecognizer *singleTapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnMenuItem:)] autorelease];
        
        [self addGestureRecognizer:singleTapGesture];

    }
    return self;
}

- (void)dealloc {
    [_contentImageView release];
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

#pragma mark - UIView's methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = _contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
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

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [_contentImageView setHighlighted:highlighted];
}


@end
