//  Created by Alejandro Isaza on 2013-08-03.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import "MBPath.h"

#include <gsim/gs_polygon.h>


@interface MBPath ()

@property (assign, nonatomic) GsPolygon polygon;

- (id)initWithGsPolygon:(GsPolygon&)polygon;

@end
