//
//  CRTNode.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTNode.h"

@implementation CRTNode

- (id)init
{
    return [self initWithName:@"" info:nil descendants:@[]];
}

- (id)initWithName:(NSString *)name info:(NSDictionary *)info descendants:(NSArray *)descendants
{
    self = [super init];
    if (self) {
        _name = name;
        _info = info;
        _descendants = [descendants mutableCopy];
    }
    return self;
}

- (CRTNode *)firstChildWithSameName:(NSString *)childName
{
    CRTNode *child = nil;
    int i = 0;
    while (!child && i < self.descendants.count) {
        CRTNode *currentChild = self.descendants[i];
        if ([currentChild.name isEqualToString:childName]) {
            child = currentChild;
        }
        i++;
    }
    return child;
}

- (void)insertChild:(CRTNode *)child
{
    if (!self.descendants) {
        self.descendants = [NSMutableArray new];
    }
    [self.descendants addObject:child];
}

@end
