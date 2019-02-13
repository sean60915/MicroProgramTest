//
//  ParkingDetailViewController.m
//  MicroProgramTest
//
//  Created by Owen Huang on 2019/2/2.
//  Copyright © 2019 Owen Huang. All rights reserved.
//

#import "ParkingDetailViewController.h"
#import "ParkingDetailCell.h"
#import "CustomAnnotation.h"
#import <MapKit/MapKit.h>

@interface ParkingDetailViewController () <UITableViewDelegate,UITableViewDataSource>
{
    double posX;
    double posY;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) ParkingDetailCell *cell;

@end

@implementation ParkingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = self.parkingName;
    
    _cell = [[ParkingDetailCell alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ParkingDetailCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ParkingDetailCell class])];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self TW97ToWGS84withTW97X:[_parkingTW97X doubleValue] TW97Y:[_parkingTW97Y doubleValue]];
    [self centerMapOnLocation];
}

- (void)centerMapOnLocation {
    //1 设置好纬度和经度
    CLLocationCoordinate2D initialLocation = {posX, posY};
    CLLocationDistance regionRadius = 1000;
    
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius * 2, regionRadius * 2);
    [self.mapView setRegion:coordinateRegion];
    
    [self createAnnotationWithCoords:initialLocation];

}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ParkingDetailCell";
    
    ParkingDetailCell *cell = (ParkingDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ParkingDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.leftLabel.text = @"停車場名稱";
        cell.rightLabel.text = self.parkingName;
    }
    else if (indexPath.row == 1) {
        cell.leftLabel.text = @"區域";
        cell.rightLabel.text = self.parkingArea;
    }
    else if (indexPath.row == 2) {
        cell.leftLabel.text = @"營業時間";
        cell.rightLabel.text = self.parkingOpenTime;
    }
    else if (indexPath.row == 3) {
        cell.leftLabel.text = @"地址";
        cell.rightLabel.text = self.parkingAddress;
    }
    
    return cell;
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D) coords {
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithCoordinate:
                                    coords];
    annotation.title = self.parkingName;
    annotation.subtitle = self.parkingAddress;
    [_mapView addAnnotation:annotation];
}


- (void)TW97ToWGS84withTW97X:(double)x TW97Y:(double)y  {
    
    double a = 6378137.0;
    double b = 6356752.314245l;
    
    double lng0 = 121 * M_PI / 180;
    double k0 = 0.9999;
    double dx = 250000.0;
    double dy = 0.0;
    double e = pow((1 - pow(b, 2) / pow(a, 2)), 0.5);
    x = x - dx;
    y = y - dy;
    double mm = y / k0;
    double mu = mm / (a * (1.0 - pow(e, 2) / 4.0 - 3 * pow(e, 4) / 64.0 - 5 * pow(e, 6) / 256.0));
    double e1 = (1.0 - pow((1.0 - pow(e, 2)), 0.5)) / (1.0 + pow((1.0 - pow(e, 2)), 0.5));
    double j1 = (3 * e1 / 2 - 27 * pow(e1, 3) / 32.0);
    double j2 = (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32.0);
    double j3 = (151 * pow(e1, 3) / 96.0);
    double j4 = (1097 * pow(e1, 4) / 512.0);
    double fp = mu + j1 * sin(2 * mu) + j2 * sin(4 * mu) + j3 * sin(6 * mu) + j4 * sin(8 * mu);
    double e2 = pow((e * a / b), 2);
    double c1 = pow(e2 * cos(fp), 2);
    double t1 = pow(tan(fp), 2);
    double r1 = a * (1 - pow(e, 2)) / pow((1 - pow(e, 2) * pow(sin(fp), 2)), (3.0 / 2.0));
    double n1 = a / pow((1 - pow(e, 2) * pow(sin(fp), 2)), 0.5);
    
    double dd = x / (n1 * k0);
    double q1 = n1 * tan(fp) / r1;
    double q2 = (pow(dd, 2) / 2.0);
    double q3 = (5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * e2) * pow(dd, 4) / 24.0;
    double q4 = (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 3 * pow(c1, 2) - 252 * e2) * pow(dd, 6) / 720.0;
    double lat = fp - q1 * (q2 - q3 + q4);
    double q5 = dd;
    double q6 = (1 + 2 * t1 + c1) * pow(dd, 3) / 6;
    double q7 = (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * e2 + 24 * pow(t1, 2)) * pow(dd, 5) / 120.0;
    double lng = lng0 + (q5 - q6 + q7) / cos(fp);
    
    // output WGS84
    lat = (lat * 180) / M_PI;
    lng = (lng * 180) / M_PI;
    
    NSLog(@"{%f,%f}",lat,lng);
    
    posX = lat;
    posY = lng;
}

@end
