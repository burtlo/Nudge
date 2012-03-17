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
    
    BOOL delegateHasTouchesBegan;
    BOOL delegateHasTouchesEnded;
}

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
    
    delegateHasTouchesBegan = [delegate respondsToSelector:@selector(quadCurveMenuItemTouchesBegan:)];
    delegateHasTouchesEnded = [delegate respondsToSelector:@selector(quadCurveMenuItemTouchesEnd:)];
    
    [self didChangeValueForKey:@"delegate"];
    
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
    
    if (delegateHasTouchesBegan) {
       [delegate_ quadCurveMenuItemTouchesBegan:self];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.contentImageView.bounds, 2.0f), location)) {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.contentImageView.bounds, 2.0f), location)) {
        if (delegateHasTouchesEnded) {
            [delegate_ quadCurveMenuItemTouchesEnd:self];
        }
    }
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
