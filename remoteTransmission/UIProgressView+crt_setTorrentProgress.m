//
//  UIProgressView+crt_setTorrentProgress.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 08/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "UIProgressView+crt_setTorrentProgress.h"

@implementation UIProgressView (crt_setTorrentProgress)

- (void)crt_setTorrentProgress:(float)percentage status:(NSInteger)status
{
    // If the torrent is done, show a full green progress bar and the total data size.
    // If the torrent is downloading, show the normal progress bar and the amount of data downloaded.
    if (percentage >= 1.0) {
        if (status == 0) {
            self.tintColor = [UIColor darkGrayColor];
        } else {
            self.tintColor = [UIColor greenColor];
        }
        [self setProgress:1.0 animated:YES];
        
    } else {
        if (status == 0) {
            self.tintColor = [UIColor darkGrayColor];
        }
        [self setProgress:percentage animated:YES];
    }
}

@end
