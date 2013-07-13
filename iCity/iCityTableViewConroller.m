//
//  iCityTableViewConroller.m
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityTableViewConroller.h"

#define CITY_LIST_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.counties%20where%20place%3D%22IN%22%20order%20by%20name&format=json"

@interface iCityTableViewConroller ()


//@property (strong, nonatomic) IBOutlet UISearchBar *citySearchBar;


@end

@implementation iCityTableViewConroller

@synthesize citySearchList, cityList, cityDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.citySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.citySearchBar.frame.size.width, self.citySearchBar.frame.size.height)];
    
//    [self.view addSubview:self.citySearchBar];
    
    
    
    [self getCityList];
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[c] %@",
                                    searchText];
    
    self.citySearchList = [self.cityList filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.citySearchList count];
    }
    else
        return self.cityList.count;
    
    return self.cityList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell...
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = [self.citySearchList objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [self.cityList objectAtIndex:indexPath.row];
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(void)getCityList
{
    //dispatch_async( dispatch_get_main_queue(), ^{
    
    
    NSData *cityData = [NSData dataWithContentsOfURL: [NSURL URLWithString:CITY_LIST_URL]];
    
    //NSLog(@"raw data : %@",cityData);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:&error];
    
    //    NSLog(@"parsed data : %@",jsonData);
    
    NSArray *lcityList = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"place"];
    
    //    NSLog(@"state list : %@",[[[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"place"] objectAtIndex:0] objectForKey:@"name"]);
    
    NSMutableDictionary *lcityDictionary = [[NSMutableDictionary alloc] initWithCapacity:100];
    NSMutableArray *tmpcityList = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    for(NSDictionary *city in lcityList)
    {
        //NSLog(@"%@ - %@",[city objectForKey:@"name"], [city objectForKey:@"woeid"]);
        
        [lcityDictionary setObject:[city objectForKey:@"woeid"] forKey:[city objectForKey:@"name"]];
        [tmpcityList addObject:[city objectForKey:@"name"]];
    }
    
    //NSLog(@"%@",cityDictionary);
    
    
    self.cityList = [NSArray arrayWithArray:[tmpcityList sortedArrayUsingComparator:^(NSString* a, NSString* b) {
        return [a compare:b options:NSNumericSearch];
    }]];
    
    self.cityDictionary = lcityDictionary;
    //    self.cityList = tmpcityList;
    
    //});
    
    
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGRect rect = self.citySearchBar.frame;
//    rect.origin.y = scrollView.contentOffset.y;
//    
//    self.citySearchBar.frame = rect;
//}

@end
