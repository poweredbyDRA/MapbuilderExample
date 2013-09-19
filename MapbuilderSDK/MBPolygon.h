//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MBFloor;
@class MBRegion;

/**
 `MBPolygon` represents a polygon on the map.
 */
@interface MBPolygon : NSObject

/**
 The ID that uniquely identifies the polygon.
 */
@property (nonatomic, retain) NSNumber* polygonID;

/**
 The name of the polygon group.
 */
@property (nonatomic, retain) NSString* group;

/**
 The polygon label.
 */
@property (nonatomic, retain) NSString* label;

/**
 The list of vertices making up the polygon.
 */
@property (nonatomic, retain) NSString* vertices;

/**
 The parent floor for the polygon.
 */
@property (nonatomic, retain) MBFloor* floor;

/**
 The region attached to the polygon, if any.
 */
@property (nonatomic, retain) MBRegion* region;

@end
