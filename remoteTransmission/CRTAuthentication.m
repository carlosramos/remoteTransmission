//
//  CRTAuthentication.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTAuthentication.h"

@implementation CRTAuthentication {
    NSString *_username;
    NSString *_password;
}

- (instancetype)init
{
    return [self initWithUsername:nil password:nil];
}

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
        if (username.length > 0 && password.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
        }
    }
    return self;
}

- (NSString *)base64Authentication
{
    if (!self.username || !self.password) {
        return nil;
    }
    
    NSString *combinedAuth = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
    NSData *data = [combinedAuth dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)username
{
    NSString *u = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if (u) {
        _username = u;
    }
    return _username;
}

- (void)setUsername:(NSString *)username
{
    _username = [username copy];
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"username"];
}

- (NSString *)password
{
    NSString *p = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (p) {
        _password = p;
    }
    return _password;
}

- (void)setPassword:(NSString *)password
{
    _password = password;
    [[NSUserDefaults standardUserDefaults] setObject:_password forKey:@"password"];
}

- (BOOL)isAuthenticated
{
    if (self.username.length > 0 && self.password.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
