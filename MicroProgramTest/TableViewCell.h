//
//  TableViewCell.h
//  MicroProgramTest
//
//  Created by Owen Huang on 2019/2/2.
//  Copyright © 2019 Owen Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *parkingName;
@property (weak, nonatomic) IBOutlet UILabel *parkingArea;
@property (weak, nonatomic) IBOutlet UILabel *parkingAddress;
@property (weak, nonatomic) IBOutlet UILabel *parkingOpenTime;

@end

NS_ASSUME_NONNULL_END
