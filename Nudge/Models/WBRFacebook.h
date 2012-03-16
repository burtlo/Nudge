//
//  WBRFacebook.h
//  Nudge
//
//  Created by Franklin Webber on 3/15/12.
//  Copyright (c) 2012 Franklin Webber, All rights reserved.
//

#import <Facebook/Facebook.h>

#define kNotificationFacebookUserAuthenticated @"facebookDidLogin"
#define kNotificationLoginResponseReceived @"userLoginResponseReceived"

@interface WBRFacebook : NSObject <FBSessionDelegate>

+ (id)sharedInstance;
- (id)initWithUserDefaults:(NSUserDefaults *)defaults;

#pragma mark - Authentication

- (BOOL)isNotAuthenticated;
- (void)authenticate;
- (void)authenticateWithPermissions:(NSArray *)permissions;
- (NSArray *)defaultPermissions;

- (void)discardCredentials;

#pragma mark 

- (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark

- (void)requestFriendsReturnResultsToDelegate:(id<FBRequestDelegate>)delegate;

@end
