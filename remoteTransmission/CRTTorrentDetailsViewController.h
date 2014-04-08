//
//  CRTTorrentDetailsViewController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 08/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRTTorrentDetailsViewController : UITableViewController
// TODO: Replace the dictionary with a full-fledged class representing a torrent.
@property (nonatomic, strong) NSDictionary *torrentDetails;
@end
