//
//  CustomAnnotation.h
//  MicroProgramTest
//
//  Created by Owen Huang on 2019/2/12.
//  Copyright © 2019 Owen Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface CustomAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
-(id) initWithCoordinate:(CLLocationCoordinate2D) coords;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@end

NS_ASSUME_NONNULL_END
