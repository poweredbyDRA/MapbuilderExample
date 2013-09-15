//  Created by Alejandro Isaza on 2013-08-04.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MBFloor;
@class MBPath;


/**
 `MBPathList` represent a path spanning multiple floors. There can be one
 path per floor.
 */
@interface MBPathList : NSObject

/**
 Initializes an `MBPathList` with a single path for a particular floor.
 
 @param path The path.
 @param floor The floor.
 
 @return The newly initialized path list.
 */
- (id)initWithPath:(MBPath*)path inFloor:(MBFloor*)floor;

/**
 The number of paths in the list.
 */
- (NSUInteger)pathCount;

/**
 Gets the path at the specified index.
 
 @param i The index.
 
 @return The path at the specified index.
 */
- (MBPath*)pathAtIndex:(NSUInteger)i;

/**
 Gets the floor at the specified index.
 
 @param i The index.
 
 @return The floor at the specified index.
 */
- (MBFloor*)floorAtIndex:(NSUInteger)i;

/**
 Enumerates each path with its corresponding floor using a block.
 
 @param block The block to call for each path, floor pair.
 */
- (void)enumeratePathsWithBlock:(void (^)(MBPath* path, MBFloor* floor, BOOL* stop))block;

/**
 Gets the total length of the paths.
 */
- (CGFloat)totalLength;

/**
 Adds a path to the path list.
 
 @param path The path to add.
 @param floor The parent floor for the path.
 */
- (void)addPath:(MBPath*)path inFloor:(MBFloor*)floor;

@end
