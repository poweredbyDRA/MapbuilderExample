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

#import "MBVenuesViewController.h"

#import "MBMapViewController.h"
#import "MBNetworking.h"


@implementation MBVenuesViewController {
    NSOperation* _fetchOperation;
    NSArray* _venues;
    NSArray* _filteredVenues;
}

- (void)dealloc {
    [_fetchOperation cancel];
}

- (void)fetch {
    if ([UIRefreshControl class])
        [self.refreshControl beginRefreshing];
    
    MBVenuesViewController __weak* wself = self;
    _fetchOperation = [[MBNetworking instance] fetchVenuesWithSuccess:^(NSArray* venues) {
        typeof(self) sself = wself;
        sself->_venues = venues;
        [sself.tableView reloadData];
        if ([UIRefreshControl class])
            [self.refreshControl endRefreshing];
    } failure:^(NSError* error) {
        NSLog(@"Error fetching venues: %@", error);
        if ([UIRefreshControl class])
            [self.refreshControl endRefreshing];
    }];
}

-(void)fetch:(MBVenue*)venue {
    MBVenuesViewController __weak* wself = self;
    _fetchOperation = [[MBNetworking instance] fetchVenueNavigation:venue withSuccess:^(MBVenue* venues) {
        [wself showVenue:venue];
    } failure:^(NSError* error) {
        NSLog(@"Error fetching venue: %@", error);
    }];
}

- (void)showVenue:(MBVenue*)venue {
    MBMapViewController* vc = [[MBMapViewController alloc] initWithNibName:nil bundle:nil];
    vc.venue = venue;
    vc.title = venue.name;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([UIRefreshControl class]) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(fetch) forControlEvents:UIControlEventValueChanged];
    }
    [self fetch];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView)
        return [_venues count];
    else
        return [_filteredVenues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Venue"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Venue"];
    
    MBVenue* venue;
    if (tableView == self.tableView)
        venue = [_venues objectAtIndex:indexPath.row];
    else
        venue = [_filteredVenues objectAtIndex:indexPath.row];
    cell.textLabel.text = venue.name;
    
    return cell;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBVenue* venue;
    if (tableView == self.tableView)
        venue = [_venues objectAtIndex:indexPath.row];
    else
        venue = [_filteredVenues objectAtIndex:indexPath.row];
    
    if ([venue.floors count] > 0)
        [self showVenue:venue];
    else
        [self fetch:venue];
}


#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    _filteredVenues = [_venues filteredArrayUsingPredicate:resultPredicate];
}

@end
