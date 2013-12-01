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

#import "MBMapViewController.h"

#import "MBElementView.h"
#import "MBFloor.h"
#import "MBMap.h"
#import "MBMapView.h"
#import "MBMapElement.h"
#import "MBNetworking.h"
#import "MBPathList.h"
#import "MBPinView.h"
#import "MBPolygon.h"
#import "MBRegion.h"
#import "MBRegionLabel.h"
#import "MBRegionsViewController.h"

#import <QuartzCore/QuartzCore.h>

#define PATH_CLEARANCE 1
#define MIN_PATH_CLEARANCE 0.1


@implementation MBMapViewController {
    NSOperation* _svgOperation;
    NSOperation* _triangulationOperation;
    
    CGPoint _origin;
    MBRegion* _originRegion;
    BOOL _originSet;
    
    MBRegion* _destinationRegion;
    MBMapElement* _destinationMapElement;
    CGPoint _destination;
    
    NSMutableArray* _searchResults;
    NSMutableDictionary* _mapElementsByName;
    NSMutableArray* _mapElementViews;
    NSMutableArray* _regionLabels;
}

- (void)setVenue:(MBVenue *)venue {
    _venue = venue;
    _floors = _venue.floors;
    _map = [[MBMap alloc] initWithVenue:_venue];
    _mapView.map = _map;
    
    [self collectElements];
    [self goToMainFloor];
    
    if (self.isViewLoaded) {
        [self createMapElements];
        [self createRegionLabels];
    }
}

- (void)setCurrentFloorIndex:(NSUInteger)index {
    _currentFloorIndex = index;
    if (index == NSNotFound) {
        _floorDownButton.enabled = NO;
        _floorUpButton.enabled = NO;
        _currentFloor = nil;
        return;
    }
    
    _floorDownButton.enabled = index > 0;
    _floorUpButton.enabled = index < _floors.count - 1;
    
    _currentFloor = _floors[index];
    if (!_currentFloor.svg)
        [self fetchSVG];
    else
        [self openSVG];

    if (!_currentFloor.triangulation)
        [self fetchTriangulation];
    else
        [self loadTriangulation];
    
    if (_currentFloor.label)
        _floorLabel.text = [NSString stringWithFormat:@"%@", _currentFloor.label];
    else
        _floorLabel.text = [NSString stringWithFormat:@"%d", index];
    
    if (self.isViewLoaded) {
        [self createMapElements];
        [self createRegionLabels];
    }
}

- (IBAction)floorUp {
    if (self.currentFloorIndex < self.floors.count - 1)
        self.currentFloorIndex += 1;
}

- (IBAction)floorDown {
    if (self.currentFloorIndex > 0)
        self.currentFloorIndex -= 1;
}

- (IBAction)clearLocation {
    [_mapView clearPath];
    _origin = CGPointZero;
    _originSet = NO;
    _locationView.hidden = YES;
    _locationView.floor = nil;
    _destinationView.hidden = YES;
    _currentPathView.hidden = YES;
}

- (IBAction)clearPath {
    [_mapView clearPath];
    _destinationView.hidden = YES;
    _currentPathView.hidden = YES;
}


#pragma mark Network methods

- (void)fetchSVG {
    _svgOperation = [[MBNetworking instance] fetchFloorSVG:_currentFloor withSuccess:^(NSData* svg) {
        [self openSVG];
    } failure:^(NSError* error) {
        NSLog(@"Error fetching SVG: %@", error);
    }];
}

- (void)fetchTriangulation {
    _triangulationOperation = [[MBNetworking instance] fetchFloorTriangulation:_currentFloor withSuccess:^(NSData* data) {
        [self loadTriangulation];
    } failure:^(NSError* error) {
        NSLog(@"Error fetching triangulation: %@", error);
    }];
}

#pragma mark helper methods

- (void)openSVG {
    if (!_currentFloor.svg)
        return;
    
    [_map loadSVG:_currentFloor.svg forFloor:_currentFloor];
    _mapView.floor = _currentFloor;
}

- (void)loadTriangulation {
    if (![_map loadTriangulation:_currentFloor.triangulation forFloor:_currentFloor]) {
        NSLog(@"Failed to load triangulation");
    }
}

- (void)collectElements {
    _mapElementsByName = [NSMutableDictionary dictionary];
    for (MBFloor* floor in _floors) {
        for (MBMapElement* element in floor.mapElements) {
            NSMutableArray* array = _mapElementsByName[element.name];
            if (!array) {
                array = [NSMutableArray array];
                _mapElementsByName[element.name] = array;
            }
            [array addObject:element];
        }
    }
}

- (void)goToMainFloor {
    self.currentFloorIndex = NSNotFound;
    for (NSUInteger i = 0; i < _floors.count; i += 1) {
        MBFloor* f = _floors[i];
        if ([f.main boolValue]) {
            self.currentFloorIndex = i;
            return;
        }
    }
    
    if (self.currentFloorIndex == NSNotFound) {
        NSLog(@"This venue has no main floor");
        if (_floors.count > 0)
            self.currentFloorIndex = 0;
    }
}

- (void)setCurrentLocation:(CGPoint)location onFloor:(MBFloor*)floor {
    _origin = location;
    _originSet = YES;
    _locationView.location = _origin;
    _locationView.floor = floor;
    _locationView.hidden = NO;
    [_mapView setNeedsLayout];
}

- (void)setDestinationLocation:(CGPoint)location onFloor:(MBFloor*)floor {
    _destination = location;
    _destinationView.location = _destination;
    _destinationView.floor = floor;
    _destinationView.hidden = NO;
    [_mapView setNeedsLayout];
}

- (void)addPathLocation:(CGPoint)location {
    if (!_originSet) {
        [self setCurrentLocation:location onFloor:_currentFloor];
        return;
    }
    
    [self setDestinationLocation:location onFloor:_currentFloor];
    
    MBPathList* pathList = [_map pathsFromLocation:_locationView.location inFloor:_locationView.floor toLocation:_destination inFloor:_currentFloor];
    if (!pathList) {
        NSLog(@"Path not found.");
        [_mapView clearPath];
    } else {
        _mapView.pathList = pathList;
    }
}

- (void)addPathToClosestMapElement:(NSString*)name {
    MBMapElement* element = [_map mapElementWithName:name closestToLocation:_origin inFloor:_currentFloor];
    _mapView.pathList = [_map pathsFromLocation:_origin inFloor:_currentFloor toMapElement:element];
}

- (void)setOriginRegion:(MBRegion*)region {
    _mapView.pathList = [_map pathsFromLocation:_origin inFloor:_currentFloor toRegion:region];
    
}


- (void)addPathElement:(MBMapElement*)element {
    [self addPathLocation:[element.location CGPointValue]];
}

- (void)showPathFrom:(MBRegion*)region {
    if (_destinationRegion)
        _mapView.pathList = [_map pathsFromRegion:region toRegion:_destinationRegion];
    else if (_destinationMapElement)
        _mapView.pathList = [_map pathsFromRegion:region toMapElement:_destinationMapElement];
}

- (void)showDestinationLabel:(NSString*)label {
    _destinationLabel.text = label;
    [_destinationContainerView addConstraint:_destinationContainerHeightConstraint];
}

- (void)hideDestinationLabel {
    [_destinationContainerView removeConstraint:_destinationContainerHeightConstraint];
}


#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.map = _map;
    _mapView.floor = _currentFloor;
    _mapView.touchDelegate = self;
    
    _locationView = [[MBPinView alloc] initWithImage:[UIImage imageNamed:@"you-are-here"]];
    _locationView.hidden = YES;
    [_mapView addAnnotation:_locationView];
    
    _destinationView = [[MBPinView  alloc] initWithImage:[UIImage imageNamed:@"destination-marker"]];
    _destinationView.hidden = YES;
    [_mapView addAnnotation:_destinationView];
    
    _floorDownButton.enabled = _currentFloorIndex > 0;
    _floorUpButton.enabled = _currentFloorIndex < _floors.count - 1;
    
    _floorLabel.font = [UIFont fontWithName:@"SansSerifBldFLF" size:100.f];
    if (_currentFloor.label)
        _floorLabel.text = [NSString stringWithFormat:@"%@", _currentFloor.label];
    else
        _floorLabel.text = [NSString stringWithFormat:@"%d", 1];
    
    _goButton.titleLabel.font = [UIFont fontWithName:@"SansSerifBookFLF" size:24.f];
    _destinationLabel.font = [UIFont fontWithName:@"SansSerifFLF" size:22.f];
    
    _origin = CGPointZero;
    _searchResults = [NSMutableArray array];
    
    [self createMapElements];
    [self createRegionLabels];
    [self hideDestinationLabel];
}

- (void)createMapElements {
    for (MBElementView* view in _mapElementViews)
        [_mapView removeAnnotation:view];
    
    _mapElementViews = [NSMutableArray array];
    for (MBMapElement* element in _currentFloor.mapElements) {
        MBElementView* view = [[MBElementView alloc] init];
        view.element = element;
        [view sizeToFit];
        [_mapView addAnnotation:view];
        [_mapElementViews addObject:view];
    }
}

- (void)createRegionLabels {
    for (MBRegionLabel* label in _regionLabels)
        [_mapView removeAnnotation:label];
    
    _regionLabels = [NSMutableArray array];
    for (MBRegion* region in _currentFloor.regions) {
        MBRegionLabel* label = [[MBRegionLabel alloc] init];
        label.map = _map;
        label.region = region;
        [label sizeToFit];
        [_mapView addAnnotation:label];
        [_regionLabels addObject:label];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    MBRegionsViewController* vc = [segue destinationViewController];
    vc.regions = [self allRegions];
    vc.onSelect = ^(MBRegion* region) {
        [self showPathFrom:region];
        
        NSUInteger index = [_floors indexOfObject:region.floor];
        if (index != NSNotFound)
            self.currentFloorIndex = index;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            CGPoint location = [_map polygonMidPoint:region.polygon];
            [self setCurrentLocation:location onFloor:region.floor];
            [_mapView scrollToLocation:location animated:YES];
        });
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    };
    vc.onCancel = ^() {
        [self dismissViewControllerAnimated:YES completion:NULL];
    };
}

- (NSArray*)allRegions {
    NSMutableArray* array = [NSMutableArray array];
    for (MBFloor* floor in _venue.floors) {
        [array addObjectsFromArray:floor.regions];
    }
    return array;
}

#pragma mark MBTouchDelegate

- (void)tapOnMapLocation:(CGPoint)location; {
    //[self addPathLocation:location];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResults count];
}


#pragma mark - UITableViewDelegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellID = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    
    id item = [_searchResults objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[MBRegion class]]) {
        MBRegion* region = item;
        cell.textLabel.text = region.name;
    } else if ([item isKindOfClass:[MBMapElement class]]) {
        MBMapElement* mapElement = item;
        cell.textLabel.text = mapElement.name;
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = item;
        cell.textLabel.text = dict[@"title"];
    } else if ([item isKindOfClass:[NSString class]]) {
        cell.textLabel.text = item;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGPoint location;
    MBFloor* floor;
    NSString* label;
    
    id item = [_searchResults objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[MBRegion class]]) {
        _destinationRegion = item;
        _destinationMapElement = nil;
        location = [_map polygonMidPoint:_destinationRegion.polygon];
        floor = _destinationRegion.floor;
        label = _destinationRegion.name;
    } else if ([item isKindOfClass:[MBMapElement class]]) {
        _destinationMapElement = item;
        _destinationRegion = nil;
        location = [_destinationMapElement.location CGPointValue];
        floor = _destinationRegion.floor;
        label = _destinationMapElement.name;
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = item;
        NSString* name = [dict objectForKey:@"title"];
        _destinationMapElement = [_map mapElementWithName:name closestToLocation:_origin inFloor:_currentFloor];
        _destinationRegion = nil;
        if (!_destinationMapElement)
            return;
        location = [_destinationMapElement.location CGPointValue];
        floor = _destinationRegion.floor;
        label = _destinationMapElement.name;
    } else if ([item isKindOfClass:[NSString class]]) {
        NSString* name = item;
        _destinationMapElement = [_map mapElementWithName:name closestToLocation:_origin inFloor:_currentFloor];
        _destinationRegion = nil;
        if (!_destinationMapElement)
            return;
        location = [_destinationMapElement.location CGPointValue];
        floor = _destinationRegion.floor;
        label = _destinationMapElement.name;
    }
    
    [self showDestinationLabel:label];
    _currentPathView.hidden = NO;
    self.searchDisplayController.active = NO;
    
    NSUInteger index = [_floors indexOfObject:floor];
    if (index != NSNotFound)
        self.currentFloorIndex = index;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self setDestinationLocation:location onFloor:floor];
        [_mapView scrollToLocation:location animated:YES];
    });
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForQuery:(NSString *)query {
    [_searchResults removeAllObjects];
    if (query.length == 0)
        return;
    
    for (NSString* name in [_mapElementsByName allKeys]) {
        NSRange nameRange = NSMakeRange(0, name.length);
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange foundRange = [name rangeOfString:query options:searchOptions range:nameRange];
        if (foundRange.length > 0)
            [_searchResults addObject:name];
    }
    
    for (MBFloor* floor in _venue.floors) {
        for (MBRegion* region in floor.regions) {
            NSString* name = region.name;
            NSRange nameRange = NSMakeRange(0, name.length);
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange foundRange = [name rangeOfString:query options:searchOptions range:nameRange];
            if (foundRange.length > 0)
                [_searchResults addObject:region];
        }
    }
}


#pragma mark - UISearchDisplayDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFilteredContentForQuery:searchString];
    return YES;
}


#pragma mark - UISearchBarDelegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar {
    [self clearLocation];
}

@end
