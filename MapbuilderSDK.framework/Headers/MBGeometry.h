//  Created by Alejandro Isaza on 2013-07-16.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#import <UIKit/UIKit.h>
#include <memory>

class GsPolygon;
class SeLct;

typedef void(^MBPathEnumerationHandler)(const CGPathElement *element);


CGPathRef MBParsePolygonAsCGPath(NSString* string);
GsPolygon MBParsePolygonAsGSPolygon(NSString* string);

void MBEnumeratePathElements(CGPathRef path, MBPathEnumerationHandler handler);
NSString* MBStringFromCGPath(CGPathRef path);

int MBFindPolygonID(const GsPolygon& poly, const std::shared_ptr<SeLct>& triangulation);
bool MBEqualPolygons(const GsPolygon& p1, const GsPolygon& p2, float tol);
