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

#import "MBElementView.h"
#import <MapbuilderSDK/MBMapElement.h>


static NSString* const StoreBackgroundImageName = @"stores";
static NSString* const KioskBackgroundImageName = @"kiosks";
static NSString* const InsideBackgroundImageName = @"inside_zones";
static NSString* const OutsideBackgroundImageName = @"outside_zones";
static NSString* const ConnectorBackgroundImageName = @"connectors";

static NSDictionary* ElementSymbols;

@implementation MBElementView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    [self createSymbolsDictionary];
    self.backgroundColor = [UIColor clearColor];
    [self create];
    return self;
}

- (void)createSymbolsDictionary {
    if (ElementSymbols)
        return;
    
    ElementSymbols = @{
        @"ATM": @"\ue03a",
        @"Bus": @"\ue039",
        @"Customer Service": @"\ue038",
        @"Elevator": @"\ue035",
        @"Entrance": @"\ue02d",
        @"Escalator": @"\ue02a",
        @"Food Court": @"\ue021",
        @"Kiosk": @"\ue03f",
        @"Pay Phone": @"\ue03c",
        @"Restroom": @"\ue02c",
        @"Stairs": @"\ue023",
    };
}

- (void)create {
    CGSize size = self.bounds.size;
    
    _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:StoreBackgroundImageName]];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backgroundImageView];
    
    _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _symbolLabel.backgroundColor = [UIColor clearColor];
    _symbolLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _symbolLabel.textColor = [UIColor whiteColor];
    _symbolLabel.font = [UIFont fontWithName:@"mallrat_font" size:13];
    _symbolLabel.textAlignment = NSTextAlignmentCenter;
    _symbolLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_symbolLabel];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(24, 24);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    _backgroundImageView.frame = CGRectMake(0, 0, size.width, size.height);
    _symbolLabel.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)setElement:(MBMapElement *)element {
    _element = element;
    switch ([_element.type integerValue]) {
        case MBMapElementStore:
            _backgroundImageView.image = [UIImage imageNamed:StoreBackgroundImageName];
            break;
            
        case MBMapElementKiosk:
            _backgroundImageView.image = [UIImage imageNamed:KioskBackgroundImageName];
            break;
            
        case MBMapElementInside:
            _backgroundImageView.image = [UIImage imageNamed:InsideBackgroundImageName];
            break;
            
        case MBMapElementOutside:
            _backgroundImageView.image = [UIImage imageNamed:OutsideBackgroundImageName];
            break;
            
        case MBMapElementConnector:
            _backgroundImageView.image = [UIImage imageNamed:ConnectorBackgroundImageName];
            break;
    }
    
    _symbolLabel.text = ElementSymbols[element.name];
    if (!_symbolLabel.text)
        NSLog(@"Symbol not found for element name: %@", element.name);
    
    [self setNeedsLayout];
}

- (CGPoint)location {
    return [_element.location CGPointValue];
}

- (MBFloor*)floor {
    return _element.floor;
}

- (BOOL)showAtScale:(CGFloat)scale {
    return YES;
}

@end
