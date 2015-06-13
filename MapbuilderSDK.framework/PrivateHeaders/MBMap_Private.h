//  Created by Alejandro Isaza on 2013-08-04.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import "MBMap.h"

#include "savage.h"
#include <gsim/se_lct.h>
#include <memory>
#include <vector>

@class MBFloor;
@class MBPolygon;


@interface MBMap ()

@property (assign, nonatomic) std::vector<std::shared_ptr<savage::SVGElement>> svgDocuments;
@property (assign, nonatomic) std::vector<std::shared_ptr<SeLct>> triangulations;

- (std::shared_ptr<savage::SVGElement>)svgDocumentForFloor:(MBFloor*)floor;
- (SeLct*)triangulationForFloor:(MBFloor*)floor;

@end
