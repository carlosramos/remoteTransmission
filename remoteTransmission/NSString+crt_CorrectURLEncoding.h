//
//  NSString+crt_CorrectURLEncoding.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 29/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (crt_CorrectURLEncoding)

/** Returns the string encoded for use on a URL.
 
  Note that the built-in method of NSString does not work for symbols
   like "&", as noted in Apple's documentation.
 */
- (NSString *)crt_URLEncodeUTF8String;

@end
