//
//  CRTNode.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRTNode : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDictionary *info;
@property (nonatomic, strong) NSMutableArray *descendants;

- (instancetype)initWithName:(NSString *)name info:(NSDictionary *)info descendants:(NSArray *)descendants;
- (CRTNode *)firstChildWithSameName:(NSString *)childName;
- (void)insertChild:(CRTNode *)child;
@end
