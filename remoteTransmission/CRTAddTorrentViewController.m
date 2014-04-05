//
//  CRTAddTorrentViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 05/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTAddTorrentViewController.h"
#import "CRTTransmissionController.h"

@interface CRTAddTorrentViewController ()
@property (nonatomic, weak) IBOutlet UITextField *torrentTextField;

- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
@end

@implementation CRTAddTorrentViewController

- (void)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneButtonTapped:(id)sender
{
    // TODO: Better validation of the URL
    if ([self.torrentTextField.text length] > 0) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        self.navigationItem.rightBarButtonItem = activityBarItem;
        [[CRTTransmissionController sharedController] addTorrent:self.torrentTextField.text
                                                  withCompletion:^(NSError *error) {
                                                      if (error) {
                                                          // TODO: Better error handling
                                                          NSLog(@"Error: %@", error);
                                                      }
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self dismissViewControllerAnimated:YES completion:NULL];
                                                      });
                                                  }];
    }
}

@end
