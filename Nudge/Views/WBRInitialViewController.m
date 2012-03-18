//
//  WBRInitialViewController.m
//  Nudge
//
//  Created by Franklin Webber on 3/15/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "WBRInitialViewController.h"
#import "WBRFacebook.h"
#import "WBRFacebookUser.h"
#import "WBRFacebookUsers.h"

#import "QuadCurveMenu.h"
#import "QuadCurveMenuItem.h"

@interface WBRInitialViewController ()

@property (strong,nonatomic) QuadCurveMenu *facebookUsersMenu;
@property (strong,nonatomic) WBRFacebookUsers *facebookUsers;

- (void)onFacebookLogin:(NSNotification *)notification;

@end

@implementation WBRInitialViewController

@synthesize facebookUsers;
@synthesize facebookUsersMenu;

#pragma mark - Initialization


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    facebookUsers = [[WBRFacebookUsers alloc] init];
    
    facebookUsersMenu = [[QuadCurveMenu alloc] initWithFrame:CGRectMake(0.0, -100.0, 320.0, 200.0) 
                                                  dataSource:facebookUsers];

    [facebookUsersMenu setContentImage:[UIImage imageNamed:@"facebook.png"]];
    [facebookUsersMenu setHighlightedContentImage:[UIImage imageNamed:@"facebook.png"]];
    [facebookUsersMenu setDelegate:self];
    
    [[self view] addSubview:facebookUsersMenu];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onFacebookLogin:) 
                                                 name:kNotificationFacebookUserAuthenticated 
                                               object:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)launchFacebook:(id)sender {
    
    if ([[WBRFacebook sharedInstance] isNotAuthenticated]) {
        [[WBRFacebook sharedInstance] authenticate];
    } else {
        [self onFacebookLogin:nil];
    }
}

#pragma mark - Notifications

- (void)onFacebookLogin:(NSNotification *)notification {
    [[WBRFacebook sharedInstance] requestFriendsReturnResultsToDelegate:self];
}

#pragma mark - FacebookRequestDelegate Adherence

- (void)requestLoading:(FBRequest *)request {
    
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response");    
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"results");
    
    [facebookUsers updateWithDictionary:result];
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"error");
    
}

#pragma mark - QuadCoreMenuDelegate

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenuItem:(QuadCurveMenuItem *)menuItem {
    NSLog(@"Tapped Menu Item");
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenuItem:(QuadCurveMenuItem *)menuItem {
    NSLog(@"Long Pressed Menu Item");
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem {
    NSLog(@"Tapped Main Menu");
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenu:(QuadCurveMenuItem *)mainMenuItem {
    NSLog(@"Long Pressed Main Menu");    
}

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu {
    return YES;
}

- (BOOL)quadCurveMenuShouldClose:(QuadCurveMenu *)menu {
    return YES;
}

- (void)quadCurveMenuWillExpand:(QuadCurveMenu *)menu {
    NSLog(@"Will Expand");
}

- (void)quadCurveMenuDidExpand:(QuadCurveMenu *)menu {
    NSLog(@"Did Expand");
}

- (void)quadCurveMenuWillClose:(QuadCurveMenu *)menu {
    NSLog(@"Will Close");
}

- (void)quadCurveMenuDidClose:(QuadCurveMenu *)menu {
    NSLog(@"Did Close");
}

@end
