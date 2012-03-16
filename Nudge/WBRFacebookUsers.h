//
//  WBRFacebookUsers.h
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveMenu.h"

@interface WBRFacebookUsers : NSObject <QuadCurveDataSourceDelegate> {
    NSMutableDictionary *facebookUsers;
}

- (id)initWithDictionary:(NSDictionary *)dataDictionary;
- (void)updateWithDictionary:(NSDictionary *)dataDictionary;

@end
