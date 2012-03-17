//
//  WBRFacebookUserMenuItem.m
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "WBRFacebookUserMenuItem.h"

@interface WBRFacebookUserMenuItem () {
    NSMutableData *imageData;
}
@end

@implementation WBRFacebookUserMenuItem


- (id)initWithFacebookUser:(WBRFacebookUser *)user {
    self = [super initWithImage:[UIImage imageNamed:@"unknown-user.png"] 
        highlightedImage:[UIImage imageNamed:@"unknown-user.png"]];
                                 
    if (self) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[user profileImageURL]];
        [NSURLConnection connectionWithRequest:request delegate:self];
        
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (imageData == nil) {
        imageData = [[NSMutableData alloc] init];
    }

    [imageData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self contentImageView] setImage:[UIImage imageWithData:imageData]];
    [[self contentImageView] setHighlightedImage:[UIImage imageWithData:imageData]];
    imageData = nil;
}

@end
