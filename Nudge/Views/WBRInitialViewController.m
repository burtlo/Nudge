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
#import "WBRFacebookMenuItemFactory.h"

#import "QuadCurveMenu.h"
#import "QuadCurveMenuItem.h"
#import "QuadCurveDefaultMenuItemFactory.h"

@interface WBRInitialViewController ()

@property (strong,nonatomic) QuadCurveMenu *facebookUsersMenu;
@property (strong,nonatomic) WBRFacebookUsers *facebookUsers;

- (void)onFacebookLogin:(NSNotification *)notification;

@end

@implementation WBRInitialViewController
@synthesize pinballRow;

@synthesize facebookUsers;
@synthesize facebookUsersMenu;

#pragma mark - Initialization


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"classy_fabric"]];
    
    [[self view] setBackgroundColor:backgroundColor];
    
    facebookUsers = [[WBRFacebookUsers alloc] init];
    
    facebookUsersMenu = [[QuadCurveMenu alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 400.0) 
                                                  dataSource:facebookUsers];

    UIImage *facebookImage = [UIImage imageNamed:@"facebook.png"];
    
    [facebookUsersMenu setMainMenuItemFactory:[[QuadCurveDefaultMainMenuItemFactory alloc] initWithImage:facebookImage andHighlightImage:facebookImage]];
    
    [facebookUsersMenu setMenuItemFactory:[[WBRFacebookMenuItemFactory alloc] init]];
    [facebookUsersMenu setDelegate:self];
    
    [[self view] addSubview:facebookUsersMenu];
    
    
    [pinballRow setDataSource:facebookUsers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onFacebookLogin:) 
                                                 name:kNotificationFacebookUserAuthenticated 
                                               object:nil];
}


- (void)viewDidUnload {
    [self setPinballRow:nil];
    [super viewDidUnload];
}

#pragma mark - Notifications

- (void)onFacebookLogin:(NSNotification *)notification {
    
    if ([facebookUsers outOfDate]) {
        [facebookUsersMenu setInProgress:YES];
        [[WBRFacebook sharedInstance] requestFriendsReturnResultsToDelegate:self];
    }
}

#pragma mark - FacebookRequestDelegate Adherence

- (void)requestLoading:(FBRequest *)request {
    
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
    [facebookUsers updateWithDictionary:result];
    [facebookUsersMenu setInProgress:NO];
    [facebookUsersMenu expandMenu];
    [pinballRow animateInFromLeft];
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
    
    if ([[WBRFacebook sharedInstance] isNotAuthenticated]) {
        [[WBRFacebook sharedInstance] authenticate];
    } else {
        [self onFacebookLogin:nil];
    }

}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenu:(QuadCurveMenuItem *)mainMenuItem {
    NSLog(@"Long Pressed Main Menu");    
}

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu {
    return ![facebookUsers outOfDate];
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

- (IBAction)letItRoll:(id)sender {
    [pinballRow animateInFromLeft];
    
}
@end
