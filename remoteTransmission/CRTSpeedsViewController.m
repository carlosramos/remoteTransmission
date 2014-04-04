//
//  CRTSpeedsViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 04/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTSpeedsViewController.h"
#import "CRTTransmissionController.h"

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CRTTransmissionController sharedController] getSpeedLimits:^(long downloadLimit, long uploadLimit, NSError *error) {
        if (error) {
            // TODO : Show message to the user and dimiss this view controller
            NSLog(@"Error trying to fetch speed limits: %@", error.localizedDescription);
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
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
                                                            // TODO: Proper error handling
                                                            NSLog(@"error: %@", error.localizedDescription);
                                                        }
                                                    }];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
