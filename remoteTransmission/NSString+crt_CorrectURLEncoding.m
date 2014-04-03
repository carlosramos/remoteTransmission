//
//  NSString+crt_CorrectURLEncoding.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 29/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "NSString+crt_CorrectURLEncoding.h"

@implementation NSString (crt_CorrectURLEncoding)

- (NSString *)crt_URLEncodeUTF8String
{
    CFStringRef foundationString = (__bridge CFStringRef)(self);
    
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                        kCFAllocatorDefault,
                                                                        foundationString,
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8);
    return CFBridgingRelease(encodedString);
}

@end
