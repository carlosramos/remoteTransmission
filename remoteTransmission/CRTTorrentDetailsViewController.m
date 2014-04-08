//
//  CRTTorrentDetailsViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 08/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTTorrentDetailsViewController.h"
#import "UIProgressView+crt_setTorrentProgress.h"

@interface CRTTorrentDetailsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *torrentName;
@property (nonatomic, weak) IBOutlet UIProgressView *torrentProgress;
@end

@implementation CRTTorrentDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    if (self.torrentDetails) {
        self.torrentName.text = self.torrentDetails[@"name"];
        NSInteger status = [self.torrentDetails[@"status"] integerValue];
        float percentDone = [self.torrentDetails[@"percentDone"] floatValue];
        [self.torrentProgress crt_setTorrentProgress:percentDone status:status];
    }
}

@end
