//
//  ViewController.m
//  MicroProgramTest
//
//  Created by Owen Huang on 2019/2/1.
//  Copyright © 2019 Owen Huang. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import <AFNetworking.h>
#import "TableViewCell.h"
#import "SDRefresh.h"
#import "ProgressHUD.h"
#import "ParkingDetailViewController.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
{
    double posX;
    double posY;
    BOOL isFiltered;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) SDRefreshHeaderView *refreshHeader;
@property (strong, nonatomic) TableViewCell *cell;
@property (strong, nonatomic) NSMutableArray *parkingArray;
@property (strong, nonatomic) NSMutableArray *searchParkingArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"停車場";
    
    isFiltered = false;
    
    [self getData];
    [self setupHeader];
    
    _cell = [[TableViewCell alloc] init];
    
    self.searchBar.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TableViewCell class])];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isFiltered) {
        
        return _searchParkingArray.count;
        
    }
    
    return _parkingArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TableViewCell";
    
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *parkDict;
    
    if (isFiltered) {
        parkDict = _searchParkingArray[indexPath.row];
    }
    else {
        parkDict = _parkingArray[indexPath.row];
    }
    
    cell.parkingArea.text = [parkDict valueForKey:@"AREA"];
    cell.parkingName.text = [parkDict valueForKey:@"NAME"];
    cell.parkingAddress.text = [parkDict valueForKey:@"ADDRESS"];
    cell.parkingOpenTime.text = [parkDict valueForKey:@"SERVICETIME"];
    
    NSLog(@"parkArea [%ld] = %@",(long)indexPath.row , cell.parkingArea);
    NSLog(@"parkingName [%ld] = %@",(long)indexPath.row , cell.parkingName);
    NSLog(@"parkingAddress [%ld] = %@",(long)indexPath.row , cell.parkingAddress);
    NSLog(@"parkingOpenTime [%ld] = %@",(long)indexPath.row , cell.parkingOpenTime);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *parkDict = _parkingArray[indexPath.row];
    
    ParkingDetailViewController *vc = [[ParkingDetailViewController alloc] init];
    vc.parkingAddress = [parkDict valueForKey:@"ADDRESS"];
    vc.parkingName = [parkDict valueForKey:@"NAME"];
    vc.parkingOpenTime = [parkDict valueForKey:@"SERVICETIME"];
    vc.parkingArea = [parkDict valueForKey:@"AREA"];
    vc.parkingTW97X = [parkDict valueForKey:@"TW97X"];
    vc.parkingTW97Y = [parkDict valueForKey:@"TW97Y"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        
        isFiltered = false;
        
        [self.searchBar endEditing:YES];
        
    }
    
    else {
        
        isFiltered = true;
        
        _searchParkingArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *parking in _parkingArray) {
            
            NSString *name = [parking valueForKey:@"NAME"];
            NSString *area = [parking valueForKey:@"AREA"];
            
            NSRange range = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange range2 = [area rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (range.location != NSNotFound || range2.location != NSNotFound) {
                
                [_searchParkingArray addObject:parking];
                
            }
            
        }
        
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Refresh

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    
    //     默认是在navigationController环境下，如果不是在此环境下，请设置
    refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:self.tableView];
    
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadingAnimation];
            [self getData];
            [weakRefreshHeader endRefreshing];
        });
    };
    
    // 进入页面自动加载一次数据
    [refreshHeader autoRefreshWhenViewDidAppear];
}

#pragma mark - Hud

- (void)loadingAnimation {
    [ProgressHUD show:@"請稍等..."];
}

- (void)hideHud {
    [ProgressHUD dismiss];
}

#pragma mark - Api

- (void)getData {
    
    [self loadingAnimation];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    params[@"name"] = @"$format";
    params[@"in"] = @"query";
    params[@"type"] = @"string";
    params[@"description"] = @"json";
    params[@"required"] = @"true";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager.securityPolicy setValidatesDomainName:NO];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    NSString *apiURL = [NSString stringWithFormat:@"http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000225-002"];
    
    [manager GET:apiURL parameters:params progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        
        [self hideHud];
        
        _parkingArray = [[NSMutableArray alloc] init];
        
        NSDictionary *responseData = [responseObject valueForKey:@"result"];
        _parkingArray = [responseData valueForKey:@"records"];
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * task, NSError *error) {
        NSLog(@"error : %@",error);
    }];
}

@end
