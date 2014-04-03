//
//  CRTDisconnectedViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 31/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTDisconnectedViewController.h"
#import "CRTLoginViewController.h"
#import "CRTTransmissionController.h"

@interface CRTDisconnectedViewController () <CRTLoginViewControllerDelegate>
- (IBAction)connectButtonTapped:(id)sender;
- (IBAction)reloginButtonTapped:(id)sender;
@end

@implementation CRTDisconnectedViewController

- (void)connectButtonTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(retryConnecting)]) {
        [self.delegate retryConnecting];
    }
}

- (void)reloginButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CRTLoginViewController *lvc = segue.destinationViewController;
    lvc.delegate = self;
}

- (void)loginViewControllerDidEnd:(CRTLoginViewController *)lvc
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(userCredentialsChanged)]) {
            [self.delegate userCredentialsChanged];
        }
    }];
}

@end
