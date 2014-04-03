//
//  CRTSettingsViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 29/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTSettingsViewController.h"

@interface CRTSettingsViewController ()
- (IBAction)doneButtonTapped:(id)sender;
@end

@implementation CRTSettingsViewController

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userWantsToLogout)]) {
        [self.delegate userWantsToLogout];
    }
}

@end
