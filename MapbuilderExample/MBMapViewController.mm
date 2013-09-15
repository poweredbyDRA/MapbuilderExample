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
#import "MBStore.h"
#import "MBStoreLabel.h"
#import "MBVendor.h"

#import <QuartzCore/QuartzCore.h>

#define PATH_CLEARANCE 1
#define MIN_PATH_CLEARANCE 0.1


@implementation MBMapViewController {
    NSOperation* _svgOperation;
    NSOperation* _triangulationOperation;
    
    CGPoint _origin;
    CGPoint _destination;
    BOOL _originSet;
    
    NSMutableArray* _searchResults;
    NSMutableDictionary* _mapElementsByName;
    NSMutableArray* _mapElementViews;
    NSMutableArray* _storeLabels;
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
        [self createStoreLabels];
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
        _floorLabel.text = [NSString stringWithFormat:@"Floor: %@", _currentFloor.label];
    else
        _floorLabel.text = [NSString stringWithFormat:@"Floor: %d", index];
    
    if (self.isViewLoaded) {
        [self createMapElements];
        [self createStoreLabels];
    }
    
    _mapView.floor = _currentFloor;
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
    _setLocationView.hidden = NO;
    _currentPathView.hidden = YES;
    self.searchDisplayController.searchBar.hidden = YES;
}

- (IBAction)clearPath {
    [_mapView clearPath];
    _destinationView.hidden = YES;
    
    _currentPathView.hidden = YES;
    self.searchDisplayController.searchBar.hidden = NO;
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
    _mapView.map = _map;
    [_mapView sizeToFit];
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

- (void)addPathLocation:(CGPoint)location {
    if (!_originSet) {
        _origin = location;
        _originSet = YES;
        _locationView.location = _origin;
        _locationView.floor = _currentFloor;
        _locationView.hidden = NO;
        _setLocationView.hidden = YES;
        self.searchDisplayController.searchBar.hidden = NO;
        [_mapView setNeedsLayout];
        return;
    }
    
    _destination = location;
    
    _destinationView.location = _destination;
    _destinationView.hidden = NO;
    [_mapView setNeedsLayout];
    
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

- (void)addPathStore:(MBStore*)store {
    if (!_originSet)
        return;
    
    _mapView.pathList = [_map pathsFromLocation:_origin inFloor:_currentFloor toStore:store];
}

- (void)addPathElement:(MBMapElement*)element {
    [self addPathLocation:[element.location CGPointValue]];
}


#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.map = _map;
    _mapView.floor = _currentFloor;
    _mapView.touchDelegate = self;
    
    _locationView = [[MBPinView alloc] initWithImage:[UIImage imageNamed:@"target"]];
    _locationView.hidden = YES;
    [_mapView addAnnotation:_locationView];
    
    _destinationView = [[MBPinView  alloc] initWithImage:[UIImage imageNamed:@"location"]];
    _destinationView.imageView.contentMode = UIViewContentModeTop;
    CGSize ds = [_destinationView sizeThatFits:CGSizeZero];
    _destinationView.bounds = CGRectMake(0, 0, ds.width, 2*ds.height);
    _destinationView.hidden = YES;
    [_mapView addAnnotation:_destinationView];
    
    _buttonsView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _buttonsView.backgroundColor = [UIColor darkGrayColor];
    _floorDownButton.enabled = _currentFloorIndex > 0;
    _floorUpButton.enabled = _currentFloorIndex < _floors.count - 1;
    
    if (_currentFloor.label)
        _floorLabel.text = [NSString stringWithFormat:@"Floor: %@", _currentFloor.label];
    else
        _floorLabel.text = [NSString stringWithFormat:@"Floor: %d", 1];
    
    _origin = CGPointZero;
    _searchResults = [NSMutableArray array];
    
    [self createMapElements];
    [self createStoreLabels];
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

- (void)createStoreLabels {
    for (MBStoreLabel* label in _storeLabels)
        [_mapView removeAnnotation:label];
    
    _storeLabels = [NSMutableArray array];
    for (MBStore* store in _currentFloor.stores) {
        MBStoreLabel* label = [[MBStoreLabel alloc] init];
        label.store = store;
        [label sizeToFit];
        [_mapView addAnnotation:label];
        [_storeLabels addObject:label];
    }
}


#pragma mark MBTouchDelegate

- (id)entityContaining:(CGPoint)point {
    return [NSValue valueWithCGPoint:point];
}

- (void)highlightEntity:(id)entity {
}

- (void)unhighlightEntity:(id)entity {
}

- (void)selectEntity:(id)entity {
    if ([entity isKindOfClass:[MBStore class]]) {
        MBStore* store = entity;
        [self addPathStore:store];
    } else if ([entity isKindOfClass:[NSValue class]]) {
        NSValue* value = entity;
        [self addPathLocation:value.CGPointValue];
    }
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
    if ([item isKindOfClass:[MBStore class]]) {
        MBStore* store = item;
        cell.textLabel.text = store.vendor.name;
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
    id item = [_searchResults objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[MBStore class]]) {
        MBStore* store = item;
        [self addPathStore:store];
        _toLabel.text = [NSString stringWithFormat:@"To: %@", store.vendor.name];
    } else if ([item isKindOfClass:[MBMapElement class]]) {
        MBMapElement* mapElement = item;
        [self addPathElement:mapElement];
        _toLabel.text = [NSString stringWithFormat:@"To: %@", mapElement.name];
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = item;
        [self addPathToClosestMapElement:[dict objectForKey:@"title"]];
        _toLabel.text = [NSString stringWithFormat:@"To: Closest %@", [dict objectForKey:@"title"]];
    } else if ([item isKindOfClass:[NSString class]]) {
        NSString* name = item;
        [self addPathToClosestMapElement:name];
        _toLabel.text = [NSString stringWithFormat:@"To: Closest %@", name];
    }
    
    _currentPathView.hidden = NO;
    self.searchDisplayController.active = NO;
    self.searchDisplayController.searchBar.hidden = YES;
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
        for (MBStore* store in floor.stores) {
            NSString* name = store.vendor.name;
            NSRange nameRange = NSMakeRange(0, name.length);
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange foundRange = [name rangeOfString:query options:searchOptions range:nameRange];
            if (foundRange.length > 0)
                [_searchResults addObject:store];
        }
    }
}


#pragma mark - UISearchDisplayControllerDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFilteredContentForQuery:searchString];
    return YES;
}


#pragma mark - UISearchBarDelegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar {
    [self clearLocation];
}

@end
