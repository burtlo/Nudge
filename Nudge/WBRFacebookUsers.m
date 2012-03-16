//
//  WBRFacebookUsers.m
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "WBRFacebookUsers.h"
#import "WBRFacebookUser.h"
#import "WBRFacebookUserMenuItem.h"

@implementation WBRFacebookUsers


- (id)init {
    self = [super init];
    if (self) {
        facebookUsers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dataDictionary {
    self = [super init];
    if (self) {
        
        facebookUsers = [NSMutableDictionary dictionary];
        
        [self updateWithDictionary:dataDictionary];
        
    }
    return self;
}

#pragma mark - Update

- (void)updateWithDictionary:(NSDictionary *)dataDictionary {
    
    for (NSDictionary *userData in [dataDictionary objectForKey:@"data"]) {
        
        NSString *userIdentifier = [userData objectForKey:@"id"];
        
        if ([facebookUsers objectForKey:userIdentifier] == nil) {
            WBRFacebookUser *user = [[WBRFacebookUser alloc] initWithDictionary:userData];
            [facebookUsers setObject:user forKey:[user identifier]];
        }
        
    }
    
    
}

#pragma mark - QuadCurveDataSourceDelegate Adherence

- (int)numberOfMenuItems {
    int countOfItems = [[facebookUsers allValues] count];
    
    if (countOfItems > 10) {
        countOfItems = 10;
    }
    
    return countOfItems;
}

- (id)menuItemAtIndex:(NSInteger)itemIndex {
    return [[WBRFacebookUserMenuItem alloc] initWithFacebookUser:[[facebookUsers allValues] objectAtIndex:itemIndex]];
}

@end
