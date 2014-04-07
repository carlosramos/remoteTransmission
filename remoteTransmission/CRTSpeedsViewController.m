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

@property (nonatomic, assign) long downloadLimit;
@property (nonatomic, assign) long uploadLimit;
@end

@implementation CRTSpeedsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [[CRTTransmissionController sharedController] getSpeedLimits:^(long downloadLimit, long uploadLimit, NSError *error) {
        if (error) {
            [UIAlertView crt_showError:error];
            [self dismissViewControllerAnimated:YES completion:NULL];
            return;
        }
        
        self.downloadLimit = downloadLimit;
        self.uploadLimit = uploadLimit;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadActivity stopAnimating];
            [self.uploadActivity stopAnimating];
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
                                                            [UIAlertView crt_showError:error];
                                                        }
                                                    }];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
