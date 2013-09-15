//  Created by Alejandro Isaza on 2013-07-28.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <UIKit/UIKit.h>


/**
 The `MBMapAnnotation` protocol defines the methods that a map annotation
 view needs to implement.
 */
@protocol MBMapAnnotation <NSObject>

/**
 Should return the location of the annotation in map coordinates.
 */
- (CGPoint)location;

/**
 Should return the floor in which this annotation is displayed.
 */
- (MBFloor*)floor;

/**
 Should return `YES` if this annotation should be shown at the specified map
 scale, `NO` if the annotation is to be hidden at that map scale.
 
 @param scale The current map scale.
 
 @return `YES` if this annotation should be shown at the specified map
 scale, `NO` otherwise.
 */
- (BOOL)showAtScale:(CGFloat)scale;

@end
