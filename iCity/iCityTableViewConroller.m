//
//  iCityTableViewConroller.m
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityTableViewConroller.h"
#import "iCityShowCityInfo.h"

#define CITY_LIST_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.counties%20where%20place%3D%22IN%22%20order%20by%20name&format=json"

#define WEATHER_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%3D00000000&format=json"

#define LOCATION_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.placefinder%20where%20woeid%3D00000000&format=json"

@interface iCityTableViewConroller ()


//@property (strong, nonatomic) IBOutlet UISearchBar *citySearchBar;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *tableDataSections;
@property (strong, nonatomic) UINavigationController *navController;



@end

@implementation iCityTableViewConroller

@synthesize citySearchList, cityList, cityDictionary, tableData, tableDataSections, navController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.citySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.citySearchBar.frame.size.width, self.citySearchBar.frame.size.height)];
    
//    [self.view addSubview:self.citySearchBar];
    
    self.tableData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableDataSections = [[NSMutableArray alloc] initWithCapacity:10];

    
    
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
    NSString *city;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        //        NSLog(@"%@ selected", [self.citySearchList objectAtIndex:indexPath.row]);
        
        city = [[NSString alloc] initWithString:[self.citySearchList objectAtIndex:indexPath.row]];
        
    }
    else
    {
        //        NSLog(@"%@ selected", [self.cityList objectAtIndex:indexPath.row]);
        
        city = [[NSString alloc] initWithString:[self.cityList objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"selected city : %@",city);
    
    [self processCity:city];

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

-(void)cancelthis
{
    NSLog(@"cancel in main view");
    [self.navController dismissViewControllerAnimated:YES completion:nil];
}

-(void)processCity:(NSString *)city
{
    
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSString *woeid = [cityDictionary objectForKey:city];
    
    NSLog(@"woeid is : %@",woeid);
    
    NSData *weatherData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[WEATHER_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]]];
    
    NSLog(@"query for weather : %@", [NSURL URLWithString:[WEATHER_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]]);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
    
    
    //    NSLog(@"parsed data : %@",jsonData);
    
    //NSArray *lcityList = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"place"];
    
    NSDictionary *item = [[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"] objectForKey:@"item"];
    
    NSString *title = [[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"] objectForKey:@"title"];
    
    [self.tableData removeAllObjects];
    [self.tableDataSections removeAllObjects];
    
    if(![title compare:@"Yahoo! Weather - Error"])
    {
        NSLog(@"weather info not found");
        [self.tableDataSections addObject:@"weather info"];
        [tableDataElement removeAllObjects];
        [tableDataElement addObject:@"not available"];
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
    }
    else
    {
        
        
        NSUInteger temperature = [[[item objectForKey:@"condition"] objectForKey:@"temp"] integerValue];
        NSString *climate = [[item objectForKey:@"condition"] objectForKey:@"text"];
        
        temperature = (temperature-32)*5/9;
        
        [self.tableData removeAllObjects];
        [self.tableDataSections removeAllObjects];
        
        
        //adding today's data
        [tableDataElement removeAllObjects];
        
        NSDictionary *todayWeather = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%u°C", temperature],[NSString stringWithFormat:@"%@", climate],@"today" ,nil] forKeys:[NSArray arrayWithObjects:@"temperature",@"climate",@"day", nil]];
        
//        [tableDataElement addObject:[NSString stringWithFormat:@"%u C", temperature]];
//        [tableDataElement addObject:[NSString stringWithFormat:@"%@", climate]];
        
        [tableDataElement addObject:todayWeather];
        
//        [self.tableData addObject:[[NSArray alloc] initWithArray:tableDataElement]];
        
        
        //weekly weather
        
        
        NSMutableArray *weekWeather = [[item objectForKey:@"forecast"] mutableCopy];
        [weekWeather removeObjectAtIndex:0];
        
        for(NSDictionary *weekday in weekWeather)
        {
            //        NSLog(@"high-low = %u - %u", [[weekday objectForKey:@"high"] integerValue], [[weekday objectForKey:@"low"] integerValue]);
            
//            [self.tableDataSections addObject:[weekday objectForKey:@"date"]];
            
            NSDictionary *todayWeather = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%u-%u", ([[weekday objectForKey:@"low"] integerValue]-32)*5/9, ([[weekday objectForKey:@"high"] integerValue]-32)*5/9],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"text"]],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"day"]] ,nil] forKeys:[NSArray arrayWithObjects:@"temperature",@"climate",@"day", nil]];
            
//            [tableDataElement addObject:[NSString stringWithFormat:@"%u - %u C", ([[weekday objectForKey:@"low"] integerValue]-32)*5/9, ([[weekday objectForKey:@"high"] integerValue]-32)*5/9]];
//            

//            [tableDataElement addObject:[NSString stringWithFormat:@"%@", [weekday objectForKey:@"text"]]];
            
            [tableDataElement addObject:todayWeather];
            
//            [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
            NSLog(@"temp : %u and climate : %@", temperature, climate);
      }
        
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
    
        NSLog(@"weather info found");
        [self.tableDataSections addObject:@"weather information"];
        [tableDataElement removeAllObjects];
        //[tableDataElement addObject:@"not available"];
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
        
    }
    
    //    NSLog(@"week info : %@", [item objectForKey:@"forecast"]);
    
    
    NSLog(@"sections : %@", self.tableDataSections);
    //    NSLog(@"table data : %@",self.tableData);
    
    iCityShowCityInfo *cityInfo = [[iCityShowCityInfo alloc] init];
    
    cityInfo.rowArray = [NSArray arrayWithArray:self.tableData];
    cityInfo.sectionArray = [NSArray arrayWithArray:self.tableDataSections];
    cityInfo.title = city;
    
    cityInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelthis)];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:cityInfo];
    
    self.navController.toolbarHidden = NO;
    self.navController.hidesBottomBarWhenPushed = YES;
    
    [self presentViewController:navController animated:YES completion:nil];
    
}


@end
