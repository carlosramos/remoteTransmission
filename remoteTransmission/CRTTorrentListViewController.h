//
//  CRTTorrentListViewController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRTLoginViewController.h"
#import "CRTSettingsViewController.h"
#import "CRTDisconnectedViewController.h"

@interface CRTTorrentListViewController : UITableViewController <CRTLoginViewControllerDelegate,
                                            UIAlertViewDelegate, CRTSettingsViewControllerDelegate,
                                            CRTDisconnectedViewControllerDelegate>

@end
