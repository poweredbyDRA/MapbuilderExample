//  Created by Alejandro Isaza on 2013-07-23.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MBFloor;

typedef enum {
    MBMapElementStore,
    MBMapElementKiosk,
    MBMapElementInside,
    MBMapElementOutside,
    MBMapElementConnector,
} MBMapElementType;

/**
 `MBMapElement` represents a point of interest in the map.
 */
@interface MBMapElement : NSObject

/**
 The ID that uniquely identifies the map element.
 */
@property (nonatomic, retain) NSNumber* mapElementID;

/**
 The name of the map element, for instance "Stairs".
 */
@property (nonatomic, retain) NSString* name;

/**
 The location of the map element in the map.
 */
@property (nonatomic, retain) NSValue* location;

/**
 The type of map element. Can be one of `MBMapElementStore` for stores, 
 `MBMapElementKiosk` got kiosks, `MBMapElementInside` for element on the main
 walking area, `MBMapElementOutside` for elements outside of the main walking
 area, and `MBMapElementConnector` for elements that connect two or more
 floors.
 */
@property (nonatomic, retain) NSNumber* type;

/**
 The containing floor for the map element.
 */
@property (nonatomic, retain) MBFloor* floor;

@end
