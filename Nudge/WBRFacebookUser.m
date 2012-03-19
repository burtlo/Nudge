//
//  WBRFacebookUser.m
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "WBRFacebookUser.h"

@interface WBRFacebookUser ()

@end

@implementation WBRFacebookUser

@synthesize dataDictionary;
@synthesize identifier;
@synthesize name;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        [self setDataDictionary:dictionary];
        
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"id"]) {
        [self setIdentifier:value];
    }
}

- (NSURL *)profileImageURL {
    NSString *profileImageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[self identifier]];
    
    return [NSURL URLWithString:profileImageURLString];
}

#pragma mark - NSCopying Adherence

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[self class]]) {
        return [[self identifier] isEqualToString:[object identifier]];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [[self identifier] hash];
}

- (id)copyWithZone:(NSZone *)zone {
    
    return [[WBRFacebookUser allocWithZone:zone] initWithDictionary:[self dataDictionary]];
    
}

@end
