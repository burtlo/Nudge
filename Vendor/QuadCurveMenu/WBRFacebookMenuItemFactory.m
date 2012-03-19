//
//  WBRFacebookMenuItemFactory.m
//  Nudge
//
//  Created by Franklin Webber on 3/19/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "WBRFacebookMenuItemFactory.h"
#import "WBRFacebookUserMenuItem.h"
#import "WBRFacebookUser.h"

@implementation WBRFacebookMenuItemFactory

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    return [[WBRFacebookUserMenuItem alloc] initWithFacebookUser:dataObject];
}

@end
