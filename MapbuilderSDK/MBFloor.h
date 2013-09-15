//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>

@class MBMapElement;
@class MBPolygon;
@class MBStore;
@class MBVenue;


/**
 `MBFloor` represents a venue floor. It contains the graphical representation
 as an SVG as well the navigation information and map elements.
 */
@interface MBFloor : NSObject

/**
 The ID that uniquely identifies the floor.
 */
@property (nonatomic, retain) NSNumber* floorID;

/**
 The floor label, usually a number but can also be few letters like MZ or G.
 */
@property (nonatomic, retain) NSString* label;

/**
 Main is a boolean value that is `true` only for the main floor.
 */
@property (nonatomic, retain) NSNumber* main;

/**
 The index position of this floor within the venue.
 */
@property (nonatomic, retain) NSNumber* position;

/**
 The SVG data for the floor's map.
 */
@property (nonatomic, retain) NSData* svg;

/**
 The navigation information for the floor.
 */
@property (nonatomic, retain) NSData* triangulation;

/**
 The parent venue for the floor.
 */
@property (nonatomic, retain) MBVenue* venue;

/**
 All the stores in the floor.
 */
@property (nonatomic, retain) NSArray* stores;

/**
 All the map elements in the floor.
 */
@property (nonatomic, retain) NSArray* mapElements;

/**
 Finds the map element with the given ID.
 
 @param mapElementID The map element unique identifier.
 
 @return The map element or 'nil' if the map element is not found.
 */
- (MBMapElement*)mapElementWithID:(NSNumber*)mapElementID;

@end
