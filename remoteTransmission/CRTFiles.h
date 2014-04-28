//
//  CRTFile.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 16/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRTTree;

@interface CRTFiles : NSObject
+ (CRTTree *)fileTreeFromTransmissionResponse:(NSDictionary *)files;
@end
