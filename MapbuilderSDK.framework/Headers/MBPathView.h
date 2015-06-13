//  Created by Alejandro Isaza on 2013-05-06.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <UIKit/UIKit.h>

@class MBFloor;
@class MBPathList;


/**
 `MBPathView` is a view that displays a path in such a way that it scales
 with a zoomable `UIScrollView` while keeping the line width constant. To do
 this the drawing transformation needs to be updated every time the underlaid
 `UIScrollView` changes the content offset or the zoom scale.
*/
@interface MBPathView : UIView

/**
 The path list to display.
 */
@property (strong, nonatomic) MBPathList* pathList;

/**
 The current floor. When the floor changes the corresponding path in the path
 list is drawn.
 */
@property (strong, nonatomic) MBFloor* floor;

/**
 The current drawing transform of the underlaid `UIScrollView`.
 */
@property (assign, nonatomic) CGAffineTransform drawingTransform;

/**
 Clears the current path list. After calling this method the path view will
 not display any content until a new path list is set.
 */
- (void)clear;

@end
