//
//  QuadCurveDefaultMenuItemFactory.m
//  Nudge
//
//  Created by Franklin Webber on 3/19/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveDefaultMenuItemFactory.h"

@implementation QuadCurveDefaultMenuItemFactory

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    
    UIImage *image = [UIImage imageNamed:@"icon-star.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"icon-star.png"];
    
    QuadCurveMenuItem *item = [[QuadCurveMenuItem alloc] initWithImage:image highlightedImage:highlightImage];
    
    [item setDataObject:dataObject];
    
    return item;
}

@end
