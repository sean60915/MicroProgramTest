//
//  ParkingDetailViewController.h
//  MicroProgramTest
//
//  Created by Owen Huang on 2019/2/2.
//  Copyright © 2019 Owen Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParkingDetailViewController : UIViewController

@property (strong,nonatomic) NSString *parkingName;
@property (strong,nonatomic) NSString *parkingArea;
@property (strong,nonatomic) NSString *parkingOpenTime;
@property (strong,nonatomic) NSString *parkingAddress;
@property (strong,nonatomic) NSString *parkingTW97X;
@property (strong,nonatomic) NSString *parkingTW97Y;

@end

NS_ASSUME_NONNULL_END
