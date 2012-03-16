//
//  WBRFacebook.m
//  Nudge
//
//  Created by Franklin Webber on 3/15/12.
//  Copyright (c) 2012 Franklin Webber, All rights reserved.
//

#import "WBRFacebook.h"

#define kFacebookApplicationID @"110140579117456"

#define kFBAccessTokenKeyName @"FBAccessTokenKey"
#define kFBExpirationDateKeyName @"FBExpirationDateKey"

#define kFacebookDefaultPermissions @"offline_access,user_about_me,user_likes,publish_stream"

@interface WBRFacebook () {
    NSUserDefaults *defaults;
    Facebook *facebook;
}

- (void)setup;

@end

@implementation WBRFacebook

#pragma mark - Initialization

+ (id)sharedInstance {
    
    static WBRFacebook *facebook;
    
    if (facebook == nil) {
        
        facebook = [[self alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
        
        [facebook setup];
    }
    
    return facebook;
}

- (id)initWithUserDefaults:(NSUserDefaults *)_defaults {
    
    self = [super init];
    if (self) {
        defaults = _defaults;
    }
    return self;
}

- (void)setup {

    NSString *facebookAppId = kFacebookApplicationID;
    
    facebook = [[Facebook alloc] initWithAppId:facebookAppId 
                                   andDelegate:self];
    
    if ([defaults objectForKey:kFBAccessTokenKeyName] 
        && [defaults objectForKey:kFBExpirationDateKeyName]) {
        
        facebook.accessToken = [defaults objectForKey:kFBAccessTokenKeyName];
        facebook.expirationDate = [defaults objectForKey:kFBExpirationDateKeyName];
    }

}

#pragma mark

- (BOOL)handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}

#pragma mark - Authentication

- (BOOL)isNotAuthenticated {
    return ![facebook isSessionValid];
}

- (void)authenticate {
    [facebook authorize:[self defaultPermissions]];
}

- (void)authenticateWithPermissions:(NSArray *)permissions {
    [facebook authorize:permissions];
}

- (NSArray *)defaultPermissions {
    return [kFacebookDefaultPermissions componentsSeparatedByString:@","];
}    

- (void)discardCredentials {
    [facebook logout];
}

#pragma mark - FBSessionDelegate Adherence


- (void)fbDidLogin {
    [defaults setObject:[facebook accessToken] forKey:kFBAccessTokenKeyName];
    [defaults setObject:[facebook expirationDate] forKey:kFBExpirationDateKeyName];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFacebookUserAuthenticated object:self];

}

- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

- (void)fbDidLogout {
    
}

- (void)fbSessionInvalidated {
    
}

- (void)requestFriendsReturnResultsToDelegate:(id<FBRequestDelegate>)delegate {
    
    [facebook requestWithGraphPath:@"me/friends" andDelegate:delegate];
    
}

@end