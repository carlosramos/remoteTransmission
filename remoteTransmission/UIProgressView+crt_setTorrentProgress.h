//
//  UIProgressView+crt_setTorrentProgress.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 08/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIProgressView (crt_setTorrentProgress)
- (void)crt_setTorrentProgress:(float)percentage status:(NSInteger)status;
@end
