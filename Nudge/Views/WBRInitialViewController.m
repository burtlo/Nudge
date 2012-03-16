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

@interface WBRFacebookUsers : NSObject <QuadCurveDataSourceDelegate> {
    NSMutableDictionary *facebookUsers;
}

- (id)initWithDictionary:(NSDictionary *)dataDictionary;
- (void)updateWithDictionary:(NSDictionary *)dataDictionary;

@end

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

    [facebookUsersMenu setImage:[UIImage imageNamed:@"facebook-hightlighted.png"]];
    [facebookUsersMenu setHighlightedImage:[UIImage imageNamed:@"facebook.png"]];

    [facebookUsersMenu setContentImage:nil];
    [facebookUsersMenu setHighlightedContentImage:nil];
    
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

@end
