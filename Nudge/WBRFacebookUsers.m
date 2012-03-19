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
    NSMutableArray *facebookUsers;
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
        //facebookUsers = [NSMutableDictionary dictionary];
        facebookUsers = [NSMutableArray array];
        
        [self updateWithDictionary:dataDictionary];
        
    }
    return self;
}

#pragma mark - Update

- (void)updateWithDictionary:(NSDictionary *)dataDictionary {
    
    int userCount = 0;
    
    for (NSDictionary *userData in [dataDictionary objectForKey:@"data"]) {
        
        userCount = userCount + 1;
        if (userCount > 10) { return; }
        
        lastUpdated = [NSDate date];
        
//        NSString *userIdentifier = [userData objectForKey:@"id"];
        
        WBRFacebookUser *user = [[WBRFacebookUser alloc] initWithDictionary:userData];
        [facebookUsers addObject:user]; 
//        
//        if ([facebookUsers objectForKey:userIdentifier] == nil) {
//            
//            [facebookUsers setObject:user forKey:[user identifier]];
//        }
        
    }
    
    
}

#pragma mark

- (BOOL)outOfDate {
    
    NSLog(@"%@ vs %@",[lastUpdated dateByAddingTimeInterval:kFacebookUsersIsStaleAfterSeconds],[NSDate date]);
    return ([[lastUpdated dateByAddingTimeInterval:kFacebookUsersIsStaleAfterSeconds] compare:[NSDate date]] == NSOrderedAscending);

}

#pragma mark - QuadCurveDataSourceDelegate Adherence

- (int)numberOfMenuItems {
    return [facebookUsers count];
//    return [[facebookUsers allValues] count];
}

- (id)menuItemAtIndex:(NSInteger)itemIndex {
    return [[WBRFacebookUserMenuItem alloc] initWithFacebookUser:[facebookUsers objectAtIndex:itemIndex]];
//    return [[WBRFacebookUserMenuItem alloc] initWithFacebookUser:[[facebookUsers allValues] objectAtIndex:itemIndex]];
}

- (void)addDataItem:(id)item {
    
    WBRFacebookUser *user = (WBRFacebookUser *)item;
//    [facebookUsers setObject:user forKey:[user identifier]];
    [facebookUsers addObject:user];
    
}

#pragma mark - PinballDataSource Adherence

- (int)numberOfItems {
    return [self numberOfMenuItems];
}

- (QuadCurveMenuItem *)itemAtIndex:(NSInteger)itemIndex {
    return [self menuItemAtIndex:itemIndex];
}

@end
