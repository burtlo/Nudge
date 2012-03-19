//
//  WBRInitialViewController.h
//  Nudge
//
//  Created by Franklin Webber on 3/15/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveMenu.h"
#import "PinballMenu.h"

@interface WBRInitialViewController : UIViewController <FBRequestDelegate,QuadCurveMenuDelegate>
- (IBAction)letItRoll:(id)sender;
@property (weak, nonatomic) IBOutlet PinballMenu *pinballRow;

@end
