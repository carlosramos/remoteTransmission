//
//  CRTSettingsViewController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 29/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRTSettingsViewControllerDelegate;

@interface CRTSettingsViewController : UITableViewController
@property (nonatomic, weak) id<CRTSettingsViewControllerDelegate> delegate;
@end

@protocol CRTSettingsViewControllerDelegate <NSObject>
- (void)userWantsToLogout;
@end
