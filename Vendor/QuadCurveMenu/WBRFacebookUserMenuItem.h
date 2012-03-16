//
//  WBRFacebookUserMenuItem.h
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveMenuItem.h"
#import "WBRFacebookUser.h"

@interface WBRFacebookUserMenuItem : QuadCurveMenuItem <NSURLConnectionDataDelegate>

- (id)initWithFacebookUser:(WBRFacebookUser *)user;

@end
