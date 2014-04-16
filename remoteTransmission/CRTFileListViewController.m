//
//  CRTFileListViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 16/04/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTFileListViewController.h"

@interface CRTFileListViewController ()

@end

@implementation CRTFileListViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *files = self.files[@"files"];
    return files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    
    NSArray *files = self.files[@"files"];
    NSDictionary *file = files[indexPath.row];
    cell.textLabel.text = file[@"name"];
    
    return cell;
}

- (void)updateFileList
{
    [self.tableView reloadData];
}

@end
