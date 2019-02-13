//
//  CustomAnnotation.m
//  MicroProgramTest
//
//  Created by Owen Huang on 2019/2/12.
//  Copyright © 2019 Owen Huang. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate, title, subtitle;

-(id) initWithCoordinate:(CLLocationCoordinate2D) coords
{
    if (self = [super init]) {
        coordinate = coords;
    }
    return self;
}

@end
