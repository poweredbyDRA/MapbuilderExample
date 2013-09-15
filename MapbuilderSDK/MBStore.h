//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>

@class MBFloor;
@class MBPolygon;
@class MBVendor;

/**
 `MBStore` represent a store on the map.
 */
@interface MBStore : NSObject

/**
 The ID that uniquely identifies the store.
 */
@property (nonatomic, retain) NSNumber* storeID;

/**
 The store's telephone number, if any.
 */
@property (nonatomic, retain) NSString* telephone;

/**
 The store's website, if any.
 */
@property (nonatomic, retain) NSString* website;

/**
 The store's email address, if any.
 */
@property (nonatomic, retain) NSString* email;

/**
 The store's description.
 */
@property (nonatomic, retain) NSString* desc;

/**
 The polygon attached to the store.
 */
@property (nonatomic, retain) MBPolygon* polygon;

/**
 The parent vendor for the store.
 */
@property (nonatomic, retain) MBVendor* vendor;

/**
 The parent floor for the store.
 */
@property (nonatomic, retain) MBFloor* floor;

@end
