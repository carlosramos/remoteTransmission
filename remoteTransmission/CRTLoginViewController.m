//
//  CRTLoginViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTLoginViewController.h"
#import "CRTTransmissionController.h"

@interface CRTLoginViewController ()
@property (nonatomic, weak) IBOutlet UITextField *hostField;
@property (nonatomic, weak) IBOutlet UITextField *portField;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@end

@implementation CRTLoginViewController

- (void)login
{
    CRTTransmissionController *transmission = [CRTTransmissionController sharedController];
    NSInteger port = [self.portField.text integerValue];
    if (port <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid port"
                                                        message:@"Port should be a positive integer."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [transmission setHost:self.hostField.text port:port];
    transmission.authentication.username = self.usernameField.text;
    transmission.authentication.password = self.passwordField.text;
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewControllerDidEnd:)]) {
        [self.delegate loginViewControllerDidEnd:self];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.portField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.hostField) {
        [self.portField becomeFirstResponder];
    } else if (textField == self.portField) {
        [self.usernameField becomeFirstResponder];
    } else if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [self login];
    }
    return YES;
}

@end
