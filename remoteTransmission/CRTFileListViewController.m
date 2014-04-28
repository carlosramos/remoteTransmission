//
//  CRTFileListViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 16/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTFileListViewController.h"
#import "CRTFiles.h"

@interface CRTFileListViewController ()

@end

@implementation CRTFileListViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentRootNode.descendants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    
    CRTNode *file = self.currentRootNode.descendants[indexPath.row];
    cell.textLabel.text = file.name;
    if (file.info == nil) {
        // If the node is a folder, info is nil
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CRTNode *newRootNode = self.currentRootNode.descendants[indexPath.row];
    CRTFileListViewController *newTableViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"FileListTableViewController"];
    newTableViewController.currentRootNode = newRootNode;

    [self.navigationController pushViewController:newTableViewController animated:YES];
}

- (void)updateFileList
{
    [self.tableView reloadData];
}

@end
