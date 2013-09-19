//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>

@class MBFloor;
@class MBPolygon;

/**
 `MBRegion` represent a region on the map.
 */
@interface MBRegion : NSObject

/**
 The ID that uniquely identifies the region.
 */
@property (nonatomic, retain) NSNumber* regionID;

/**
 The name of the region.
 */
@property (nonatomic, retain) NSString* name;

/**
 The polygon attached to the region.
 */
@property (nonatomic, retain) MBPolygon* polygon;

/**
 The parent floor for the region.
 */
@property (nonatomic, retain) MBFloor* floor;

@end
