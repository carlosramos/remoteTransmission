//
//  CRTFileListViewController.h
//  remoteTransmission
//
//  Created by Carlos Ramos on 16/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRTTree.h"

@interface CRTFileListViewController : UITableViewController

@property (nonatomic, strong) CRTTree *files;
@property (nonatomic, weak) CRTNode *currentRootNode;

- (void)updateFileList;
@end
