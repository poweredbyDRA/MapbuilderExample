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

#import "MBMapView.h"
#import <UIKit/UIKit.h>

@class MBFloor;
@class MBHighlightView;
@class MBMap;
@class MBMapView;
@class MBPathView;
@class MBPinView;
@class MBTriangulationView;
@class MBVenue;

@class SASVGView;


@interface MBMapViewController : UIViewController <MBTouchDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet MBMapView* mapView;

@property (weak, nonatomic) IBOutlet UILabel* floorLabel;
@property (weak, nonatomic) IBOutlet UIView* currentPathView;

@property (weak, nonatomic) IBOutlet UIView* destinationContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* destinationContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel* destinationLabel;

@property (weak, nonatomic) IBOutlet UIView* buttonsView;
@property (weak, nonatomic) IBOutlet UIButton* floorDownButton;
@property (weak, nonatomic) IBOutlet UIButton* floorUpButton;
@property (weak, nonatomic) IBOutlet UIButton* goButton;

@property (strong, nonatomic) MBPinView* locationView;
@property (strong, nonatomic) MBPinView* destinationView;

@property (strong, nonatomic) MBMap* map;
@property (strong, nonatomic) MBVenue* venue;
@property (assign, nonatomic) NSUInteger currentFloorIndex;
@property (strong, nonatomic, readonly) NSArray* floors;
@property (strong, nonatomic, readonly) MBFloor* currentFloor;

- (IBAction)floorUp;
- (IBAction)floorDown;
- (IBAction)clearLocation;
- (IBAction)clearPath;

@end
