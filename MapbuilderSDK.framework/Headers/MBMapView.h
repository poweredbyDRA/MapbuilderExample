//  Created by Alejandro Isaza on 2013-07-28.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import "MBMap.h"
#import "MBMapAnnotation.h"
#import <UIKit/UIKit.h>

@protocol MBTouchDelegate;


/**
 `MBMapView` is the main view used for displaying maps. 
 */
@interface MBMapView : UIView

///-------------------------------------------------------------------------
/// @name Configuring a Map View
///-------------------------------------------------------------------------

/**
 The delegate to use for handling touch events.
 */
@property (weak, nonatomic) id<MBTouchDelegate> touchDelegate;

/**
 The map to show.
 */
@property (strong, nonatomic) MBMap* map;

/**
 The current floor. Set this property to any floor on the venue to display
 that floor.
 */
@property (strong, nonatomic) MBFloor* floor;

/**
 The scroll view content insets for the map. Set these if you have iOS7
 see-through bars around the map. You also need to set
 `automaticallyAdjustsScrollViewInsets` to `NO` in the view controller.
 */
@property (nonatomic) UIEdgeInsets mapInsets;

- (void)scrollToLocation:(CGPoint)location animated:(BOOL)animated;


///------------------
/// @name Annotations
///------------------

/**
 Adds an annotation to the map view. Annotations keep their positions but
 are not scaled as the map is zoomed. Each annotation has a specific floor
 and appears only if the map view is currently displaying that floor.
 
 @param annotation The annotation to add.
 
 @see MBMapAnnotation
 */
- (void)addAnnotation:(UIView<MBMapAnnotation>*)annotation;

/**
 Removes an annotation from the map view.
 
 @param annotation The annotation to remove.
 */
- (void)removeAnnotation:(UIView<MBMapAnnotation>*)annotation;


///------------------
/// @name Paths
///------------------

/**
 The path list to display on the map view. Each path in the path list
 corresponds to a specific floor.
 */
@property (strong, nonatomic) MBPathList* pathList;

/**
 Clears the current path list. No path will be displayed on any floor until
 a new path list is set.
 */
- (void)clearPath;

@end


/**
 The `MBTouchDelegate` protocol defines the methods that a delegate of an
 `MBMapView` should to implement to handle touch events.
 */
@protocol MBTouchDelegate <NSObject>

/**
 Tells the delegate that a tap ocurred.
 
 @param location The location in map coordinates where the tap ocurred.
 */
- (void)tapOnMapLocation:(CGPoint)location;

@end
