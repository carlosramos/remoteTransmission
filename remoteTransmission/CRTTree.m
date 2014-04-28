//
//  CRTTree.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTTree.h"
#import "CRTNode.h"

@implementation CRTTree

- (id)init
{
    self = [super init];
    if (self) {
        _rootNode = [[CRTNode alloc] initWithName:@"/" info:nil descendants:@[]];
    }
    return self;
}



@end
