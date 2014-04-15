//
//  CRTTorrentDetailsViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 08/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTTorrentDetailsViewController.h"
#import "UIProgressView+crt_setTorrentProgress.h"
#import "UIAlertView+crt_ShowError.h"
#import "CRTTransmissionController.h"

const int kStartTorrent = 1;
const int kStopTorrent = 0;

@interface CRTTorrentDetailsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *torrentName;
@property (nonatomic, weak) IBOutlet UIProgressView *torrentProgress;
@end

@implementation CRTTorrentDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    if (self.torrentDetails) {
        self.torrentName.text = self.torrentDetails[@"name"];
        [self updateProgressBar];
        [self updateStartStopButton];
    }
}

- (void)updateStartStopButton
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    NSInteger status = [self.torrentDetails[@"status"] integerValue];
    cell.textLabel.text = (status == 0) ? @"Start" : @"Stop";
}

- (void)updateProgressBar
{
    NSInteger status = [self.torrentDetails[@"status"] integerValue];
    float percentDone = [self.torrentDetails[@"percentDone"] floatValue];
    [self.torrentProgress crt_setTorrentProgress:percentDone status:status];
}

- (void)startOrStopTorrent:(int)startStop
{
    if (self.torrentDetails && self.torrentDetails[@"id"]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSNumber *torrentID = self.torrentDetails[@"id"];
        void (^completionBlock)(NSError *) = ^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if (error) {
                    [UIAlertView crt_showError:error];
                } else {
                    self.torrentDetails[@"status"] = (startStop == kStopTorrent) ? @0 : @1;
                    [self updateProgressBar];
                    [self updateStartStopButton];
                }
            });
        };
        if (startStop == kStopTorrent) {
            [[CRTTransmissionController sharedController] stopTorrent:torrentID.integerValue withCompletion:completionBlock];
        } else {
            [[CRTTransmissionController sharedController] startTorrent:torrentID.integerValue withCompletion:completionBlock];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        if ([self.torrentDetails[@"status"] integerValue] == 0) {
            [self startOrStopTorrent:kStartTorrent];
        } else {
            [self startOrStopTorrent:kStopTorrent];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
