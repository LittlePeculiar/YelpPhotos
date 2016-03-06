//
//  GMHomeViewController.m
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import "GMHomeViewController.h"
#import "GMYelpAPI.h"
#import "GMSearchResultInfo.h"
#import "GMCoreDataManager.h"
#import "GMHomeTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>


#define kDefaultSearchTerm      @"pho"
#define kDefaultSearchLoc       @"92648"
#define kHideTopConstant        -100
#define kShowTopConstant        25

@interface GMHomeViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSString *searchLoc;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isSearchBoxShowing;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBoxTopConstraint;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *searchContainerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTermTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *dragImageView;

@end

@implementation GMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeUPGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeUPGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.searchContainerView addGestureRecognizer:swipeUPGesture];
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.searchContainerView addGestureRecognizer:swipeDownGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.searchContainerView addGestureRecognizer:tapGesture];
    self.isSearchBoxShowing = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.searchTerm =[[NSUserDefaults standardUserDefaults] objectForKey:@"LastSearchTerm"];
    self.searchLoc = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastSearchLocation"];
    if (self.searchTerm == nil) {
        self.searchTerm = kDefaultSearchTerm;
    }
    if (self.searchLoc == nil) {
        self.searchLoc = kDefaultSearchLoc;
    }
    
    // load table with any saved data, location manager should update accordingly
    [self refreshTableData];
    
#if TARGET_IPHONE_SIMULATOR
    // location services doesnt play will with simulator
    [self fetchSearchResultsFromAPI];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.searchBoxTopConstraint.constant = kHideTopConstant;
    
    // find current location to search location
    [self updateCurrentLocation];
}

- (void)saveLastSearch
{
    // save last search
    [[NSUserDefaults standardUserDefaults] setObject:self.searchTerm forKey:@"LastSearchTerm"];
    [[NSUserDefaults standardUserDefaults] setObject:self.searchLoc forKey:@"LastSearchLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateCurrentLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ([self isLocationManagerAuthorized:status] == NO) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else {
        [self.locationManager startUpdatingLocation];
    }
}

- (BOOL)isLocationManagerAuthorized:(CLAuthorizationStatus)status
{
    if ([CLLocationManager locationServicesEnabled] == YES) {
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                return NO;
                
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                return YES;
        }
    }
    else {
        return NO;
    }
}

- (void)fetchSearchResultsFromAPI
{
    GMYelpAPI *api = [GMYelpAPI sharedManager];
    [api fetchSearchResultsForTerm:self.searchTerm andLocation:self.searchLoc completionHandler:^(BOOL isSaved, NSError *error) {
        if (isSaved == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshTableData];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // something bad happened
                NSString *title = @"Search Request Failed";
                NSString *message = @"Please try again";
                [self showAlert:title andMessage:message];
                [self addNetworkObserver];
            });
        }
    }];
}

- (void)refreshTableData
{
    self.tableData = [[GMCoreDataManager sharedManager] fetchSearchResultsForTerm:self.searchTerm];
    if (self.tableData.count > 0) {
        [self.tableView reloadData];
    }
}

- (void)showAlert:(NSString*)title andMessage:(NSString*)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                               // do some thing here
                           }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self hideSearchBox];
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        [self showSearchBox];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer*)gesture
{
    if (self.isSearchBoxShowing) {
        [self hideSearchBox];
    }
    else  {
        [self showSearchBox];
    }
    
    self.isSearchBoxShowing = !self.isSearchBoxShowing;
}

- (void)showSearchBox
{
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchBoxTopConstraint.constant = kShowTopConstant;
        [self.searchTermTextfield becomeFirstResponder];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSearchBox
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchBoxTopConstraint.constant = kHideTopConstant;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonSelected:(id)sender {
    
    [self.view endEditing:YES];
    [self hideSearchBox];
    if (self.searchTermTextfield.text.length > 0) {
        // TODO
        // add validation
        self.searchTerm = self.searchTermTextfield.text;
        [self fetchSearchResultsFromAPI];
        [self saveLastSearch];
        self.searchTermTextfield.text = @"";
    }
}

- (void)checkNetworkConnection
{
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].reachable;
    if (isReachable) {
        [self fetchSearchResultsFromAPI];
    }
}

- (void)addNetworkObserver
{
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkConnection)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
}

// MARK: Tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"HomeTableViewCellID";
    GMHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    GMCellData *data = [self.tableData objectAtIndex:indexPath.row];
    [cell setData:data];
    return cell;
}

// MARK: LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([self isLocationManagerAuthorized:status] == YES) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:manager.location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if (error != nil) {
            NSString *title = @"Unable to find your current location";
            NSString *message = @"Please check your network connection and try again";
            [self showAlert:title andMessage:message];
            [self addNetworkObserver];
        }
        if (placemarks.count > 0) {
            
            CLPlacemark *placemark = placemarks.firstObject;
            if (placemark.postalCode != nil) {
                self.searchLoc = placemark.postalCode;
                [self fetchSearchResultsFromAPI];
                [self saveLastSearch];
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
}

// MARk: TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        self.searchTerm = textField.text;
        [self fetchSearchResultsFromAPI];
        [self hideSearchBox];
        self.searchTermTextfield.text = @"";
    }
    
    return YES;
}


@end
