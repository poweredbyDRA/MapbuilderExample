//
// Copyright (c) 2013 Synergy Media
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>

@class MBVenue;
@class MBFloor;


@interface MBNetworking : NSObject

@property (strong, nonatomic) NSString* apiKey;
@property (strong, nonatomic, readonly) AFHTTPClient* client;

+ (instancetype)instance;

- (NSOperation*)fetchVenuesWithSuccess:(void (^)(NSArray* venues))success failure:(void (^)(NSError *error))failure;
- (NSOperation*)fetchVenueDetails:(MBVenue*)venue withSuccess:(void (^)(MBVenue* venue))success failure:(void (^)(NSError *error))failure;
- (NSOperation*)fetchVenueNavigation:(MBVenue*)venue withSuccess:(void (^)(MBVenue* venue))success failure:(void (^)(NSError *error))failure;
- (NSOperation*)fetchVenueStores:(MBVenue*)venue withSuccess:(void (^)(NSArray* stores))success failure:(void (^)(NSError* error))failure;

- (NSOperation*)fetchFloorSVG:(MBFloor*)floor withSuccess:(void (^)(NSData* svg))success failure:(void (^)(NSError *error))failure;
- (NSOperation*)fetchFloorTriangulation:(MBFloor*)floor withSuccess:(void (^)(NSData* triangulation))success failure:(void (^)(NSError *error))failure;

@end
