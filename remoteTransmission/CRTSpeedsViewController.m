//
//  CRTSpeedsViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 04/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTSpeedsViewController.h"
#import "CRTTransmissionController.h"
#import "UIAlertView+crt_ShowError.h"

@interface CRTSpeedsViewController ()
- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@property (nonatomic, weak) IBOutlet UITextField *downloadLimitTextField;
@property (nonatomic, weak) IBOutlet UITextField *uploadLimitTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *downloadActivity;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *uploadActivity;

@property (nonatomic, assign) BOOL altSpeedsEnabled;

@property (nonatomic, assign) long downloadLimit;
@property (nonatomic, assign) long uploadLimit;
@end

@implementation CRTSpeedsViewController

- (void)showErrorAndDismissViewController:(NSError *)error
{
    [UIAlertView crt_showError:error];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CRTTransmissionController sharedController] getSpeedLimits:^(long downloadLimit, long uploadLimit, NSError *error) {
        if (error) {
            [self performSelectorOnMainThread:@selector(showErrorAndDismissViewController:) withObject:error waitUntilDone:NO];
            return;
        }
        
        [[CRTTransmissionController sharedController] getAltSpeedsEnabled:^(BOOL altSpeedsEnabled, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [self showErrorAndDismissViewController:error];
                    return;
                }
                self.downloadLimit = downloadLimit;
                self.uploadLimit = uploadLimit;
                        
            
                [self.downloadActivity stopAnimating];
                [self.uploadActivity stopAnimating];
                
                self.altSpeedsEnabled = altSpeedsEnabled;
                [self.tableView reloadData];
                
                self.downloadLimitTextField.hidden = NO;
                if (self.downloadLimit == 0) {
                    self.downloadLimitTextField.text = @"";
                } else {
                    self.downloadLimitTextField.text = [NSString stringWithFormat:@"%ld", self.downloadLimit];
                }
                self.uploadLimitTextField.hidden = NO;
                if (self.uploadLimit == 0) {
                    self.uploadLimitTextField.text = @"";
                } else {
                    self.uploadLimitTextField.text = [NSString stringWithFormat:@"%ld", self.uploadLimit];
                }
            });
        }];
    }];
}

- (void)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneTapped:(id)sender
{
    self.downloadLimit = [self.downloadLimitTextField.text integerValue];
    self.uploadLimit = [self.uploadLimitTextField.text integerValue];
    [[CRTTransmissionController sharedController] setDownloadLimit:self.downloadLimit
                                                       uploadLimit:self.uploadLimit
                                                    withCompletion:^(NSError *error) {
                                                        if (error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [UIAlertView crt_showError:error];
                                                            });
                                                        }
                                                    }];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = self.altSpeedsEnabled ? @"Turn Off Slow Mode" : @"Turn On Slow Mode";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        BOOL setAltSpeed = self.altSpeedsEnabled ? NO : YES;
        [[CRTTransmissionController sharedController] setAltSpeeds:setAltSpeed withCompletion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                if (error) {
                    [self showErrorAndDismissViewController:error];
                    return;
                } else {
                    self.altSpeedsEnabled = self.altSpeedsEnabled ? NO : YES;
                    [self.tableView reloadData];
                }
            });
        }];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
