//
//  WBRAppDelegate.m
//  Nudge
//
//  Created by Franklin Webber on 3/15/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "WBRAppDelegate.h"
#import "WBRFacebook.h"

@implementation WBRAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    return YES;
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation {

    return [[WBRFacebook sharedInstance] handleOpenURL:url];
}
@end
