//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>

@class MBStore;

/**
 `MBVendor` represents a store vendor.
 */
@interface MBVendor : NSObject

/**
 The ID that uniquely identifies this vendor.
 */
@property (nonatomic, retain) NSNumber* vendorID;

/**
 The vendor's name.
 */
@property (nonatomic, retain) NSString* name;

/**
 The vendor's website, if any.
 */
@property (nonatomic, retain) NSString* website;

/**
 All the stores belonging to this vendor.
 */
@property (nonatomic, retain) NSArray* stores;

@end
