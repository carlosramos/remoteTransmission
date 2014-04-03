//
//  CRTDisconnectedViewController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 31/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRTDisconnectedViewControllerDelegate;

@interface CRTDisconnectedViewController : UIViewController
@property (nonatomic, weak) id<CRTDisconnectedViewControllerDelegate> delegate;
@end

@protocol CRTDisconnectedViewControllerDelegate <NSObject>
- (void)retryConnecting;
- (void)userCredentialsChanged;
@end
