//
//  WBRFacebookUser.h
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBRFacebookUser : NSObject <NSCopying>

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSURL *)profileImageURL;

@property (nonatomic,strong) NSDictionary *dataDictionary;
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;

@end
