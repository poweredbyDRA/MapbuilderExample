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

#import "MBMap.h"
#import "MBPolygon.h"
#import "MBRegion.h"
#import "MBRegionLabel.h"
#import <QuartzCore/QuartzCore.h>


@implementation MBRegionLabel {
    CGRect _bb;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    self.backgroundColor = [UIColor clearColor];
    self.font = [UIFont fontWithName:@"SansSerifBookFLF" size:13.f];
    self.shadowColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.shadowOffset = CGSizeMake(0, 1);
    self.textAlignment = NSTextAlignmentCenter;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 2;
    return self;
}

- (void)setRegion:(MBRegion *)region {
    _region = region;
    
    self.text = region.name;
    _bb = [_map polygonBoundingBox:_region.polygon];
    
    CGSize size;
    size.width = [[self class] longestWordWidthInString:self.text withFont:self.font];
    size.height = self.numberOfLines * [self.font lineHeight];
    while (size.width < 320) {
        CGSize s = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(size.width, HUGE_VALF) lineBreakMode:NSLineBreakByWordWrapping];
        if (s.height <= size.height) {
            size.width = s.width;
            break;
        }
        size.width += 20;
    }
    
    self.bounds = CGRectMake(0, 0, size.width, size.height);
}

+ (CGFloat)longestWordWidthInString:(NSString*)string withFont:(UIFont*)font {
    CGFloat longest = 0;
    NSArray* words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString* word in words) {
        CGSize size = [word sizeWithFont:font];
        if (size.width > longest)
            longest = size.width;
    }
    return longest;
}

- (MBFloor*)floor {
    return _region.floor;
}

- (CGPoint)location {
    return [_map polygonMidPoint:_region.polygon];
}

- (BOOL)showAtScale:(CGFloat)scale {
    CGSize size = self.bounds.size;
    return size.width <= _bb.size.width * scale * 1.5;
}

@end
