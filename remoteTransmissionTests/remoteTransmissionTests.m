//
//  remoteTransmissionTests.m
//  remoteTransmissionTests
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRTTransmissionController.h"

@interface remoteTransmissionTests : XCTestCase
@property (nonatomic, strong) CRTTransmissionController *transmissionController;
@property (nonatomic, copy) NSString *expectedAuthString;
@end

@implementation remoteTransmissionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.transmissionController = [[CRTTransmissionController alloc] init];
    self.transmissionController.authentication.username = @"carlos";
    self.transmissionController.authentication.password = @"hello";
    self.expectedAuthString = [NSString stringWithFormat:@"Basic %@", [self.transmissionController.authentication base64Authentication]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


@end
