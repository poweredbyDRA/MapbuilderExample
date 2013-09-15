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

#import "MBMapElement+Mapping.h"

@implementation MBMapElement (Mapping)

+ (EKObjectMapping*)mapping {
    EKObjectMapping* mapping = [[EKObjectMapping alloc] initWithObjectClass:[MBMapElement class]];
    [mapping mapFieldsFromArray:@[
     @"name"
     ]];
    [mapping mapFieldsFromDictionary:@{
     @"id": @"mapElementID",
     }];
    [mapping mapKey:@"location" toField:@"location" withValueBlock:^(NSString* key, NSString* value) {
        NSArray* components = [value componentsSeparatedByString:@","];
        CGPoint point;
        point.x = [[components[0] substringFromIndex:1] floatValue];
        point.y = [components[1] floatValue];
        return [NSValue valueWithCGPoint:point];
    }];
    [mapping mapKey:@"type" toField:@"type" withValueBlock:(id)^(NSString* key, NSString* value) {
        if ([value isEqualToString:@"store"])
            return @(MBMapElementStore);
        if ([value isEqualToString:@"kiosk"])
            return @(MBMapElementKiosk);
        if ([value isEqualToString:@"inside_zone"])
            return @(MBMapElementInside);
        if ([value isEqualToString:@"outside_zone"])
            return @(MBMapElementOutside);
        if ([value isEqualToString:@"connector"])
            return @(MBMapElementConnector);
        return @(MBMapElementStore);
    }];
    return mapping;
}

@end
