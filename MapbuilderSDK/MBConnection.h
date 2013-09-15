//  Created by Alejandro Isaza on 2013-08-01.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>

@class MBVenue;


/**
 `MBConnection` represents a connection between two map elements.
 */
@interface MBConnection : NSObject

/**
 The id of the source map element.
 */
@property (nonatomic, retain) NSNumber* sourceID;

/**
 The id of the destination map element.
 */
@property (nonatomic, retain) NSNumber* targetID;

/**
 A reference to the parent venue.
 */
@property (nonatomic, retain) MBVenue* venue;

@end
