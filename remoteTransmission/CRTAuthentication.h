//
//  CRTAuthentication.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRTAuthentication : NSObject
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (instancetype)init;
- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;
- (NSString *)base64Authentication;
- (BOOL)isAuthenticated;
@end
