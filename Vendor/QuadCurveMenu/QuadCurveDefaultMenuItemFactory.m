//
//  QuadCurveDefaultMenuItemFactory.m
//  Nudge
//
//  Created by Franklin Webber on 3/19/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveDefaultMenuItemFactory.h"

@interface QuadCurveDefaultMainMenuItemFactory () {
    UIImage *image;
    UIImage *highlightImage;
}

@end

@implementation QuadCurveDefaultMainMenuItemFactory

- (id)init {
    return [self initWithImage:[UIImage imageNamed:@"icon-plus.png"]
             andHighlightImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
}

- (id)initWithImage:(UIImage *)image_ andHighlightImage:(UIImage *)highlightImage_ {
    
    self = [super init];
    if (self) {
        
        image = image_;
        highlightImage = highlightImage_;
        
    }
    return self;
}

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    
    
    QuadCurveMenuItem *item = [[QuadCurveMenuItem alloc] initWithImage:image 
                                                      highlightedImage:highlightImage];
    
    [item setDataObject:dataObject];
    
    return item;
}

@end



@implementation QuadCurveDefaultMenuItemFactory

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    
    UIImage *image = [UIImage imageNamed:@"icon-star.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"icon-star.png"];
    
    QuadCurveMenuItem *item = [[QuadCurveMenuItem alloc] initWithImage:image highlightedImage:highlightImage];
    
    [item setDataObject:dataObject];
    
    return item;
}

@end
