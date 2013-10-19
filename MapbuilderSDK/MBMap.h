//  Created by Alejandro Isaza on 2013-05-10.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@class MBFloor;
@class MBMapElement;
@class MBVenue;
@class MBPath;
@class MBPathList;
@class MBPolygon;
@class MBRegion;


/**
 An `MBMap` contains all of the information necessary to draw and navigate a
 venue. It contains methods to find paths between two locations within a venue
 and helper methods to deal with polygons.
 */
@interface MBMap : NSObject

///-------------------------------------------------------------------------
/// @name Initializing a Map
///-------------------------------------------------------------------------

/**
 Initializes an `MBMap` with the specified venue.
 
 @param venue The venue.

 @return An initialized map.
 */
- (id)initWithVenue:(MBVenue*)venue;

/**
 Loads the SVG data for the specified floor.
 
 @param data The SVG data to load.
 @param floor The floor this SVG belongs to.
 
 @return `YES` if the SVG was loaded successfully, `NO` otherwise.
 */
- (BOOL)loadSVG:(NSData*)data forFloor:(MBFloor*)floor;

/**
 Loads the navigation information for the specified floor.
 
 @param data The navigation data.
 @param floor the floors this navigation information belongs to.
 
 @return `YES` if the navigation data was loaded successfully, `NO` otherwise.
 */
- (BOOL)loadTriangulation:(NSData*)data forFloor:(MBFloor*)floor;


///-------------------------------------------------------------------------
/// @name Configuring a Map
///-------------------------------------------------------------------------

/**
 The target venue for the map.
 */
@property (strong, nonatomic, readonly) MBVenue* venue;

/**
 The preferred path clearance, in map units, for the generated paths. The
 path clearance is the minimum distance allowed between the path and any
 wall or obstacle. The path-finding algorithm will try to find a path with
 this clearance but will reduce the clearance if necessary.
 */
@property (assign, nonatomic) float preferredPathClearance;

/**
 The minimum path clearance allowed, in map units. The path clearance is
 the minimum distance allowed between the path and any wall or obstacle. The
 path-finding algorithm will start with the preferred clearance and reduce
 it down to the minimum distance if it can't find a path.
 */
@property (assign, nonatomic) float minimumPathClearance;


///-------------------------------------------------------------------------
/// @name Path Finding
///-------------------------------------------------------------------------

/**
 Finds a path list from a location in a floor to another location in another
 (or the same) floor.
 
 @param loc1 The initial location.
 @param floor1 The initial floor.
 @param loc2 The target location.
 @param floor2 The target floor.
 
 @return An `MBPathList` with a series of paths between the initial location
 and the target location, or an empty path list if no such path exists.
 */
- (MBPathList*)pathsFromLocation:(CGPoint)loc1 inFloor:(MBFloor*)floor1
                      toLocation:(CGPoint)loc2 inFloor:(MBFloor*)floor2;

/**
 Finds a path list from one region to another.
 
 @param origin The initial region.
 @param destination The target region.
 
 @return An `MBPathList` with a series of paths between the initial region
 and the target region, or an empty path list if no such path exists.
 */
- (MBPathList*)pathsFromRegion:(MBRegion*)origin toRegion:(MBRegion*)destination;

/**
 Finds a path list from a region to a map element.
 
 @param origin The initial region.
 @param destination The target map element.
 
 @return An `MBPathList` with a series of paths between the initial region
 and the target map element, or an empty path list if no such path exists.
 */
- (MBPathList*)pathsFromRegion:(MBRegion*)origin toMapElement:(MBMapElement*)destination;

/**
 Finds a path list from a location to a region.
 
 @param loc The initial location.
 @param floor The initial floor.
 @param region The target region.
 
 @return An `MBPathList` with a series of paths between the initial location
 and the region, or an empty path list if no such path exists.
 */
- (MBPathList*)pathsFromLocation:(CGPoint)loc inFloor:(MBFloor*)floor
                         toRegion:(MBRegion*)region;

/**
 Finds a path list from a location to a map element.

 @param loc The initial location.
 @param floor The initial floor.
 @param element The target map element.

 @return An `MBPathList` with a series of paths between the initial location
 and the map element, or an empty path list if no such path exists.
 */
- (MBPathList*)pathsFromLocation:(CGPoint)loc inFloor:(MBFloor*)floor
                    toMapElement:(MBMapElement*)element;

/**
 Finds a path from an initial location to a target location on the same floor.
 
 @param loc1 The initial location.
 @param loc2 The target location.
 @param floor The floor.
 
 @return An `MBPath` from the initial location to the target location or
 `nil` if no such path exists.
 */
- (MBPath*)pathFromLocation:(CGPoint)loc1 toLocation:(CGPoint)loc2
                    inFloor:(MBFloor*)floor;

/**
 Finds the closes map element to a specified location, given the name of
 the map element.
 
 @param name The name of the map element to look for.
 @param origin The initial location.
 @param floor The initial floor.
 
 @return The map element that is closest to the specified location or `nil`
 if no element with the specified name can be reached.
 */
- (MBMapElement*)mapElementWithName:(NSString*)name
                  closestToLocation:(CGPoint)origin inFloor:(MBFloor*)floor;


///-------------------------------------------------------------------------
/// @name Working with Polygons
///-------------------------------------------------------------------------

/**
 Gets the middle point of a polygon. The middle point is the center of the
 polygon's bounding box.
 
 @param polygon The polygon.
 
 @return The middle point of the polygon.
 */
- (CGPoint)polygonMidPoint:(MBPolygon*)polygon;

/**
 Gets the bounding box of a polygon.
 
 @param polygon The polygon.
 
 @return The bounds rectable of the polygon.
 */
- (CGRect)polygonBoundingBox:(MBPolygon*)polygon;

@end
