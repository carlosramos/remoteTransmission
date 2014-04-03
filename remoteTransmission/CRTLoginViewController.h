//
//  CRTLoginViewController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRTLoginViewControllerDelegate;

@interface CRTLoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) id<CRTLoginViewControllerDelegate> delegate;
@end

@protocol CRTLoginViewControllerDelegate <NSObject>
- (void)loginViewControllerDidEnd:(CRTLoginViewController *)lvc;
@end