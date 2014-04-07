//
//  UIAlertView+crt_ShowError.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 07/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "UIAlertView+crt_ShowError.h"

@implementation UIAlertView (crt_ShowError)

+ (void)crt_showError:(NSError *)error
{
    [self crt_showAlertWithTitle:@"Error" message:error.localizedDescription];
}

+ (void)crt_showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
