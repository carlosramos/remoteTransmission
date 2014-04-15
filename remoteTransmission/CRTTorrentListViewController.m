//
//  CRTTorrentListViewController.m
//  remoteTransmission
//
//  Created by Carlos Ramos on 28/03/14.
//  Copyright (c) 2014 Carlos Ramos González. All rights reserved.
//

#import "CRTTorrentListViewController.h"
#import "CRTTransmissionController.h"
#import "CRTTorrentDetailsViewController.h"
#import "UIProgressView+crt_setTorrentProgress.h"

@interface CRTTorrentListViewController ()
@property (nonatomic, strong) CRTTransmissionController *transmission;
@property (nonatomic, strong) NSMutableArray *torrentList;
@property (nonatomic, strong) NSDictionary *sessionStats;

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UILabel *portOpen;

@property (nonatomic, assign) long long downloadSpeed;
@property (nonatomic, assign) long long uploadSpeed;

@property (nonatomic, strong) UIBarButtonItem *duItem;

@property (nonatomic, assign, getter = isDisconnected) BOOL disconnected;
@property (nonatomic, assign) BOOL showLoginView;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL updateTimerAfterFetchingData;

- (void)fetchDataFromServer;
- (void)updateUI;
- (void)handleFetchingError:(NSError *)error;
@end

@implementation CRTTorrentListViewController

#pragma mark - Data fetching & consequent UI logic

/** Show an error alert and set the state to disconnected. Switch to the disconnected view
    after the alert has been dismissed (alert view delegate) */
- (void)handleFetchingError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.disconnected = YES;
    [alert show];
}

- (void)updateUI
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    
    // Update session stats...
    self.downloadSpeed = [self.sessionStats[@"downloadSpeed"] longLongValue];
    self.uploadSpeed = [self.sessionStats[@"uploadSpeed"] longLongValue];
    
    // ...and the list of torrents
    [self.tableView reloadData];
}

- (void)fetchDataFromServer
{
    if (self.isDisconnected) {
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.transmission torrentList:^(NSArray *list, NSError *error) {
        if (error) {
            [self performSelectorOnMainThread:@selector(handleFetchingError:) withObject:error waitUntilDone:NO];
            return;
        }
        
        [self.transmission sessionStats:^(NSDictionary *stats, NSError *error) {
            if (error) {
                [self performSelectorOnMainThread:@selector(handleFetchingError:) withObject:error waitUntilDone:NO];
                return;
            }
            
            self.torrentList = [list mutableCopy];
            self.sessionStats = stats;
            [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
        }];
    }];
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transmission = [CRTTransmissionController sharedController];
    self.torrentList = [NSMutableArray array];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Toolbar views configuration.
    self.navigationController.toolbarHidden = NO;
    
    CGRect labelFrame = CGRectMake(0, 0, 80, 40);
    self.portOpen = [[UILabel alloc] initWithFrame:labelFrame];
    self.portOpen.font = [UIFont systemFontOfSize:12.0];
    self.portOpen.text = @"";
    
    self.duItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(downloadTapped:)];
    
    UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *itemPort = [[UIBarButtonItem alloc] initWithCustomView:self.portOpen];
    self.toolbarItems = @[self.duItem, flexibleSeparator, itemPort];
    
    self.disconnected = YES;
    
    if (self.transmission.host.length == 0 || self.transmission.port <= 0) {
        self.showLoginView = YES;
    } else if (!self.transmission.authentication.isAuthenticated) {
        self.showLoginView = YES;
    } else {
        self.showLoginView = NO;
        self.disconnected = NO;
        self.updateTimerAfterFetchingData = YES;
        [self fetchDataFromServer];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.showLoginView) {
        self.showLoginView = NO;
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

#pragma mark - Misc. target/action methods

- (void)refreshControlChanged:(id)sender
{
    [self fetchDataFromServer];
}

- (void)downloadTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showSpeeds" sender:self];
}


#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self performSegueWithIdentifier:@"showNoConnection" sender:self];
}


#pragma mark - Timers

- (void)startTimer
{
    if (self.updateTimerAfterFetchingData == NO) {
        return;
    }
    
    // TODO: The interval should be configurable by the user.
    self.updateTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    self.updateTimerAfterFetchingData = NO;
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
}

- (void)invalidateTimers
{
    [self.updateTimer invalidate];
}

- (void)timerFired:(NSTimer *)timer
{
    self.updateTimerAfterFetchingData = YES;
    [self fetchDataFromServer];
}

#pragma mark - Login View Controller Delegate

- (void)loginViewControllerDidEnd:(CRTLoginViewController *)lvc
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (self.transmission.authentication.isAuthenticated) {
        self.showLoginView = NO;
        self.disconnected = NO;
        self.updateTimerAfterFetchingData = YES;
        [self fetchDataFromServer];
    }
}


#pragma mark - Settings View Controller Delegate

- (void)userWantsToLogout
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self invalidateTimers];

        [self.transmission cancelAllTasks];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.torrentList removeAllObjects];
        self.downloadSpeed = self.uploadSpeed = 0;
        
        [self.transmission setHost:nil port:0];
        self.transmission.authentication.username = nil;
        self.transmission.authentication.password = nil;
        
        self.showLoginView = YES;
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }];
}

#pragma mark - Disconnected View C. delegate

- (void)retryConnecting
{
    [self dismissViewControllerAnimated:NO completion:^{
        self.disconnected = NO;
        self.updateTimerAfterFetchingData = YES;
        [self fetchDataFromServer];
    }];
}

- (void)userCredentialsChanged
{
    self.showLoginView = NO;
    [self dismissViewControllerAnimated:NO completion:^{
        self.disconnected = NO;
        self.updateTimerAfterFetchingData = YES;
        [self fetchDataFromServer];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.torrentList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TorrentCell" forIndexPath:indexPath];
    
    NSDictionary *torrent = self.torrentList[indexPath.row];
    NSNumber *totalSize = torrent[@"totalSize"];
    
    UILabel *titulo = (UILabel *)[cell viewWithTag:200];
    UILabel *tam = (UILabel *)[cell viewWithTag:201];
    UIProgressView *prog = (UIProgressView *)[cell viewWithTag:202];
    
    titulo.text = torrent[@"name"];
    
    NSInteger status = [torrent[@"status"] integerValue];
    float percentDone = [torrent[@"percentDone"] floatValue];
    
    [prog crt_setTorrentProgress:percentDone status:status];
    
    if (percentDone >= 1.0) {
        tam.text = [self humanReadableSize:totalSize.longLongValue];
    } else {
        float downloaded = totalSize.longLongValue * percentDone;
        tam.text = [NSString stringWithFormat:@"%@ de %@", [self humanReadableSize:downloaded],
                    [self humanReadableSize:totalSize.longLongValue]];
    }
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        CRTLoginViewController *lvc = segue.destinationViewController;
        lvc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController *navController = segue.destinationViewController;
        CRTSettingsViewController *svc = (CRTSettingsViewController *)navController.topViewController;
        svc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showNoConnection"]) {
        UINavigationController *navController = segue.destinationViewController;
        CRTDisconnectedViewController *dvc = (CRTDisconnectedViewController *)navController.topViewController;
        dvc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"torrentDetails"]) {
        CRTTorrentDetailsViewController *tdvc = segue.destinationViewController;
        NSMutableDictionary *torrent = [self.torrentList[self.tableView.indexPathForSelectedRow.row] mutableCopy];
        tdvc.torrentDetails = torrent;
    }
}

#pragma mark - Helper methods

/** Returns a human readable (i.e. "4 GB" instead of 4000000) representation of a number of bytes.
    Please be aware that this method uses S.I. standard units (1000 divisor instead of 1024). This
    is needed to be consistent with the desktop Transmission representation.
 */
- (NSString *)humanReadableSize:(long long)size
{
    NSArray *names = @[@"KB", @"MB", @"GB", @"TB"];
    
    float newSize = size;
    NSInteger i = 0;
    while (newSize > 1000) {
        if (newSize / 1000 < 1000) {
            return [NSString stringWithFormat:@"%.1f %@", newSize/1000, names[i]];
        }
        newSize /= 1000;
        i++;
    }
    return [NSString stringWithFormat:@"%lld %@", size, @"B"];
}


- (void)setDownloadSpeed:(long long)downloadSpeed
{
    _downloadSpeed = downloadSpeed;
    self.duItem.title = [NSString stringWithFormat:@"%@ / %@",
                         [self humanReadableSize:downloadSpeed],
                         [self humanReadableSize:self.uploadSpeed]];
}

- (void)setUploadSpeed:(long long)uploadSpeed
{
    _uploadSpeed = uploadSpeed;
    self.duItem.title = [NSString stringWithFormat:@"%@ / %@",
                         [self humanReadableSize:self.downloadSpeed],
                         [self humanReadableSize:uploadSpeed]];
}

@end
