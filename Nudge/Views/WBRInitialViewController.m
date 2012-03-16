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
#import "WBRFacebookUserMenuItem.h"

#import "QuadCurveMenu.h"
#import "QuadCurveMenuItem.h"

@interface WBRInitialViewController ()

@property (strong,nonatomic) QuadCurveMenu *facebookUsers;

- (void)onFacebookLogin:(NSNotification *)notification;

@end

@implementation WBRInitialViewController

@synthesize facebookUsers;

#pragma mark - Initialization


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    QuadCurveMenuItem *starMenuItem1 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed 
                                                                   ContentImage:starImage 
                                                        highlightedContentImage:nil];

    
    facebookUsers = [[QuadCurveMenu alloc] initWithFrame:CGRectMake(0.0, -100.0, 320.0, 200.0) menus:[NSArray arrayWithObject:starMenuItem1]];

    [facebookUsers setImage:[UIImage imageNamed:@"facebook-hightlighted.png"]];
    [facebookUsers setHighlightedImage:[UIImage imageNamed:@"facebook.png"]];

    [facebookUsers setContentImage:nil];
    [facebookUsers setHighlightedContentImage:nil];
    
    [[self view] addSubview:facebookUsers];
    
    
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

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response");    
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"results");
    
    NSMutableArray *users = [NSMutableArray array];
    
    for (NSDictionary *userData in [result objectForKey:@"data"]) {
        
        WBRFacebookUser *user = [[WBRFacebookUser alloc] initWithDictionary:userData];
        
        [users addObject:user];
    }
    
    NSMutableArray *menuItems = [NSMutableArray array];

    for (int x = 0; x < 10; x++) {

        WBRFacebookUserMenuItem *item = [[WBRFacebookUserMenuItem alloc] initWithFacebookUser:[users objectAtIndex:x]];
        
        [menuItems addObject:item];
        
    }
    
    [facebookUsers setMenusArray:menuItems];
    
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"error");
    
}

@end
