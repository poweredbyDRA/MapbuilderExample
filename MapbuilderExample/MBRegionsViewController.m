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

#import "MBRegionsViewController.h"

static NSString* const CELL_IDENTIFIER = @"region";
static const CGFloat CELL_HEIGHT = 44.f;


@interface MBRegionsViewController ()
@property (strong, nonatomic) NSArray* sectionTitles;
@property (strong, nonatomic) NSDictionary* sectionContents;
@property (strong, nonatomic) NSArray* filteredRegions;
@end


@implementation MBRegionsViewController

- (void)setRegions:(NSArray *)regions {
    _regions = regions;
    
    NSMutableSet* titles = [NSMutableSet set];
    NSMutableDictionary* contents = [NSMutableDictionary dictionary];
    for (MBRegion* region in regions) {
        NSString* title = [[region.name substringToIndex:1] uppercaseString];
        [titles addObject:title];
        
        NSMutableArray* array = contents[title];
        if (!array) {
            array = [NSMutableArray array];
            contents[title] = array;
        }
        [array addObject:region];
    }
    
    _sectionTitles = [titles sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES] ]];
    _sectionContents = [contents copy];
}

- (IBAction)cancel {
    if (_onCancel)
        _onCancel();
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_filteredRegions) {
        return _filteredRegions.count;
    } else {
        NSString* title = _sectionTitles[section];
        NSArray* contents = _sectionContents[title];
        return contents.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MBRegion* region;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (_filteredRegions) {
        region = [_filteredRegions objectAtIndex:indexPath.row];
    } else {
        NSString* section = _sectionTitles[indexPath.section];
        NSArray* contents = _sectionContents[section];
        region = [contents objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = region.name;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_filteredRegions)
        return 1;
    else
        return _sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sectionTitles[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBRegion* region;
    if (_filteredRegions) {
        region = [_filteredRegions objectAtIndex:indexPath.row];
    } else {
        NSString* section = _sectionTitles[indexPath.section];
        NSArray* contents = _sectionContents[section];
        region = [contents objectAtIndex:indexPath.row];
    }
    
    if (_onSelect)
        _onSelect(region);
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchText];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _filteredRegions = nil;
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    _filteredRegions = [_regions filteredArrayUsingPredicate:resultPredicate];
}

@end
