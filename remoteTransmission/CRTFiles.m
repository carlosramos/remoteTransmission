//
//  CRTFile.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 16/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTFiles.h"
#import "CRTTree.h"
#import "CRTNode.h"

@implementation CRTFiles

+ (NSDictionary *)fileInfoFromTransmissionInfo:(NSDictionary *)file stats:(NSDictionary *)stats
{
    NSDictionary *d = @{@"bytesCompleted": file[@"bytesCompleted"],
                        @"length": file[@"length"],
                        @"wanted": stats[@"wanted"],
                        @"priority": stats[@"priority"]};
    return d;
}

+ (CRTTree *)fileTreeFromTransmissionResponse:(NSDictionary *)files
{
    CRTTree *tree = [CRTTree new];
    NSArray *filesArray = files[@"files"];
    NSArray *statsArray = files[@"fileStats"];
    for (int i = 0; i < filesArray.count; i++) {
        NSDictionary *file = filesArray[i];
        NSDictionary *stats = statsArray[i];
        
        NSString *filePath = file[@"name"];
        NSArray *pathComponents = [filePath pathComponents];
        CRTNode *currentNode = tree.rootNode;
        for (NSString *pathComponent in pathComponents) {
            CRTNode *child = [currentNode firstChildWithSameName:pathComponent];
            if (child == nil) {
                child = [[CRTNode alloc] initWithName:pathComponent info:nil descendants:@[]];
                [currentNode insertChild:child];
                if (pathComponent == [pathComponents lastObject]) {
                    child.info = [self fileInfoFromTransmissionInfo:file stats:stats];
                }
            }
            currentNode = child;
        }
    }
    return tree;
}

@end
