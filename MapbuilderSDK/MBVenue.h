//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <Foundation/Foundation.h>

@class MBConnection;
@class MBFloor;
@class MBMapElement;
@class MBPath;
@class MBStore;


/**
 `MBVenue` represents a venue containing a number of floors and all the
 navigation information.
 */
@interface MBVenue : NSObject

@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSNumber* latitude;
@property (nonatomic, retain) NSNumber* longitude;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* state;
@property (nonatomic, retain) NSNumber* venueID;
@property (nonatomic, retain) NSString* website;
@property (nonatomic, retain) NSString* zipcode;

/**
 The array of floors for the venue.
 */
@property (nonatomic, retain) NSArray* floors;

/**
 All the connections between venue floors.
 */
@property (nonatomic, retain) NSArray* connections;

@end
