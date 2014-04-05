//
//  CRTViewControllerUtilities.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 05/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTViewControllerUtilities.h"

@implementation CRTViewControllerUtilities

+ (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
