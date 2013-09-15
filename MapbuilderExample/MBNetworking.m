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

#import "MBNetworking.h"

#import "MBVenue+Mapping.h"
#import "MBFloor+Mapping.h"
#import "MBStore+Mapping.h"

#define MB_HOST @"poweredbydra.com"
#define MB_SCHEME @"https"


@implementation MBNetworking

+ (instancetype)instance {
    static MBNetworking* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    NSString* urlString = [NSString stringWithFormat:@"%@://%@", MB_SCHEME, MB_HOST];
    _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:urlString]];
    [_client setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void)setApiKey:(NSString *)apiKey {
    _apiKey = apiKey;
    [_client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", _apiKey]];
}

- (AFHTTPRequestOperation*)fetchVenuesOperation {
    NSURLRequest* request = [_client requestWithMethod:@"GET" path:@"api/venues" parameters:nil];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (NSOperation*)fetchVenuesWithSuccess:(void (^)(NSArray* venues))success failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperation* op = [self fetchVenuesOperation];
    op.allowsInvalidSSLCertificate = YES;
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id response) {
        // Parse response
        NSError* error;
        NSArray* venueDicts = [[NSJSONSerialization JSONObjectWithData:response options:0 error:&error] objectForKey:@"venues"];
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        NSArray* venues = [EKMapper arrayOfObjectsFromExternalRepresentation:venueDicts withMapping:[MBVenue mapping]];
        if (success)
            success(venues);
    } failure:^(AFHTTPRequestOperation* op, NSError* error) {
        if (failure)
            failure(error);
    }];
    
    [_client enqueueHTTPRequestOperation:op];
    return op;
}

- (AFHTTPRequestOperation*)fetchVenueOperation:(MBVenue*)venue {
    NSString* path = [NSString stringWithFormat:@"api/venues/%@", venue.venueID];
    NSURLRequest* request = [_client requestWithMethod:@"GET" path:path parameters:nil];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (NSOperation*)fetchVenueDetails:(MBVenue*)venue withSuccess:(void (^)(MBVenue* venue))success failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperation* op = [self fetchVenueOperation:venue];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id response) {
        // Parse response
        NSError* error;
        NSDictionary* venueDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        [EKMapper fillObject:venue fromExternalRepresentation:venueDict withMapping:[MBVenue mapping]];
        
        if (success)
            success(venue);
    } failure:^(AFHTTPRequestOperation* op, NSError* error) {
        if (failure)
            failure(error);
    }];
    
    [_client enqueueHTTPRequestOperation:op];
    return op;
}

- (AFHTTPRequestOperation*)fetchVenueNavigationOperation:(MBVenue*)venue {
    NSString* path = [NSString stringWithFormat:@"api/venues/%@/navigation", venue.venueID];
    NSURLRequest* request = [_client requestWithMethod:@"GET" path:path parameters:nil];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (NSOperation*)fetchVenueNavigation:(MBVenue*)venue withSuccess:(void (^)(MBVenue* venue))success failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperation* op = [self fetchVenueNavigationOperation:venue];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id response) {
        // Parse response
        NSError* error;
        NSDictionary* venueDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        [EKMapper fillObject:venue fromExternalRepresentation:venueDict withMapping:[MBVenue mapping]];
        
        // Fill parent references
        for (MBConnection* c in venue.connections)
            c.venue = venue;
        for (MBFloor* floor in venue.floors) {
            floor.venue = venue;
            for (MBMapElement* elem in floor.mapElements)
                elem.floor = floor;
            for (MBStore* store in floor.stores)
                store.floor = floor;
        }
        
        if (success)
            success(venue);
    } failure:^(AFHTTPRequestOperation* op, NSError* error) {
        if (failure)
            failure(error);
    }];
    
    [_client enqueueHTTPRequestOperation:op];
    return op;
}

- (AFHTTPRequestOperation*)fetchVenueStoresOperation:(MBVenue*)venue {
    NSString* path = [NSString stringWithFormat:@"api/venues/%@/stores", venue.venueID];
    NSURLRequest* request = [_client requestWithMethod:@"GET" path:path parameters:nil];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (NSOperation*)fetchVenueStores:(MBVenue*)venue withSuccess:(void (^)(NSArray* stores))success failure:(void (^)(NSError* error))failure {
    AFHTTPRequestOperation* op = [self fetchVenueStoresOperation:venue];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id response) {
        // Parse response
        NSError* error;
        NSDictionary* storesDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        NSArray* stores = [EKMapper arrayOfObjectsFromExternalRepresentation:[storesDict objectForKey:@"stores"] withMapping:[MBStore mapping]];
       
        if (success)
            success(stores);
    } failure:^(AFHTTPRequestOperation* op, NSError* error) {
        if (failure)
            failure(error);
    }];
    
    [_client enqueueHTTPRequestOperation:op];
    return op;
}

- (AFHTTPRequestOperation*)fetchFloorSVGOperation:(MBFloor*)floor {
    NSString* path = [NSString stringWithFormat:@"api/floors/%@/svg", floor.floorID];
    NSURLRequest* request = [_client requestWithMethod:@"GET" path:path parameters:nil];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (NSOperation*)fetchFloorSVG:(MBFloor*)floor withSuccess:(void (^)(NSData* svg))success failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperation* op = [self fetchFloorSVGOperation:floor];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id response) {
        floor.svg = response;
        if (success)
            success(response);
    } failure:^(AFHTTPRequestOperation* op, NSError* error) {
        if (failure)
            failure(error);
    }];
    
    [_client enqueueHTTPRequestOperation:op];
    return op;
}

- (AFHTTPRequestOperation*)fetchFloorTriangulationOperation:(MBFloor*)floor {
    NSString* path = [NSString stringWithFormat:@"api/floors/%@/triangulation", floor.floorID];
    NSURLRequest* request = [_client requestWithMethod:@"GET" path:path parameters:nil];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

- (NSOperation*)fetchFloorTriangulation:(MBFloor*)floor withSuccess:(void (^)(NSData* triangulation))success failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperation* op = [self fetchFloorTriangulationOperation:floor];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id response) {
        floor.triangulation = response;
        if (success)
            success(response);
    } failure:^(AFHTTPRequestOperation* op, NSError* error) {
        if (failure)
            failure(error);
    }];
    
    [_client enqueueHTTPRequestOperation:op];
    return op;
}

@end
