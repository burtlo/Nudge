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

#define kFacebookUsersIsStaleAfterSeconds 600

@interface WBRFacebookUsers () {
    NSDate *lastUpdated;
}

@end

@implementation WBRFacebookUsers

#pragma mark - Initialization

- (id)init {
    return [self initWithDictionary:[NSMutableDictionary dictionary]];
}

- (id)initWithDictionary:(NSDictionary *)dataDictionary {
    self = [super init];
    if (self) {
        
        lastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
        facebookUsers = [NSMutableDictionary dictionary];
        
        [self updateWithDictionary:dataDictionary];
        
    }
    return self;
}

#pragma mark - Update

- (void)updateWithDictionary:(NSDictionary *)dataDictionary {
    
    for (NSDictionary *userData in [dataDictionary objectForKey:@"data"]) {
        
        lastUpdated = [NSDate date];
        
        NSString *userIdentifier = [userData objectForKey:@"id"];
        
        if ([facebookUsers objectForKey:userIdentifier] == nil) {
            WBRFacebookUser *user = [[WBRFacebookUser alloc] initWithDictionary:userData];
            [facebookUsers setObject:user forKey:[user identifier]];
        }
        
    }
    
    
}

#pragma mark

- (BOOL)outOfDate {
    
    NSLog(@"%@ vs %@",[lastUpdated dateByAddingTimeInterval:kFacebookUsersIsStaleAfterSeconds],[NSDate date]);
    return ([[lastUpdated dateByAddingTimeInterval:kFacebookUsersIsStaleAfterSeconds] compare:[NSDate date]] == NSOrderedAscending);

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

#pragma mark - PinballDataSource Adherence

- (int)numberOfItems {
    return [self numberOfMenuItems];
}

- (QuadCurveMenuItem *)itemAtIndex:(NSInteger)itemIndex {
    return [self menuItemAtIndex:itemIndex];
}

@end
