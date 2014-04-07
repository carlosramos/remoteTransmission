//
//  UIAlertView+crt_ShowError.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 07/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (crt_ShowError)
/** Shows in an alert view with title "Error" the message given by error.localizedDescription.
 @param error The error object.
 */
+ (void)crt_showError:(NSError *)error;
/** Shows an alert view.
 @param title The title of the alert view.
 @param message The alert message.
 */
+ (void)crt_showAlertWithTitle:(NSString *)title message:(NSString *)message;
@end
