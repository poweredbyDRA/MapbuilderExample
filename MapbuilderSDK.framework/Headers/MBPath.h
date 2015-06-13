//  Created by Alejandro Isaza on 2013-08-03.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 `MBPath` represents a path between to points on the same floor.
 */
@interface MBPath : NSObject

/**
 Initializes an `MBPath` object with a C array of vertices.
 
 @param vertices A pointer to C array of vertices.
 @param count The number of vertices.
 
 @return The newly initialized path.
 */
- (id)initWithVertices:(CGPoint*)vertices count:(NSUInteger)count;

/**
 Initializes an `MBPath` object with an array of vertices.
 
 @param array An `NSArray` of vertices.
 
 @return The newly initialized path.
 */
- (id)initWithVertexArray:(NSArray*)array;

/**
 The number of vertices on the path.
 */
- (NSUInteger)vertexCount;

/**
 Gets the location of a vertex.
 
 @param index The index.
 @return The location of the vertex at the given index.
 */
- (CGPoint)vertexAtIndex:(NSUInteger)index;

/**
 The total distance of the path.
 */
- (CGFloat)length;

@end
