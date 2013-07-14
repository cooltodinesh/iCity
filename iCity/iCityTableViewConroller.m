//
//  iCityTableViewConroller.m
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityTableViewConroller.h"
#import "iCityShowCityInfo.h"
#import "iCityAppDelegate.h"
#import "iCityFriendDetails.h"

#define CITY_LIST_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.counties%20where%20place%3D%22IN%22%20order%20by%20name&format=json"

#define WEATHER_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%3D00000000&format=json"

#define LOCATION_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.placefinder%20where%20woeid%3D00000000&format=json"

#define HOSPITAL_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20google.search%20where%20q%3D%22Hospital%20in%20AAAAAAAA%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"

#define HOTEL_URL @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20google.search%20where%20q%3D%22Hotels%2FRestaurent%20in%20AAAAAAAA%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"

#define GOOGLE_API @"https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q="

#define LOCATION_DATA  @"locationData"
#define FRIEND_DATA    @"friendArrayData"
#define LATITUDE       @"latitude"
#define LONGITUDE      @"longitude"
#define CITY_PIC       @"city_pic"
#define CITY_ID        @"city_id"
#define FRIEND_NAME    @"name"
#define FRIEND_CITY    @"subtitle"
#define PROFILE_IMAGE  @"profile_image"
#define CITY_PIC       @"city_pic"

#define FETCHING_FRIENDS 0
#define FETCHING_CITIES 1

#define AVERAGE_FRIENDS 10



@interface iCityTableViewConroller () <FBSessionDelegate, FBRequestDelegate>
{
    int currentAction;

}

//@property (strong, nonatomic) IBOutlet UISearchBar *citySearchBar;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *tableDataSections;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) UIActivityIndicatorView *activity;

@property (strong, nonatomic) NSMutableDictionary *cityToFriendMappingG;

@property (strong, nonatomic) NSMutableArray *cityFriendDictionaryArrayG;

@property (strong, nonatomic) NSMutableDictionary *friendPictures;

@end

@implementation iCityTableViewConroller

@synthesize citySearchList, cityList, cityDictionary, tableData, tableDataSections, navController, activity, cityFriendDictionaryArrayG, cityToFriendMappingG, friendPictures;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 20, 20)];
    
    self.activity.hidden = YES;
    
    self.cityToFriendMappingG = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.cityFriendDictionaryArrayG  = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableDataSections = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.friendPictures = [[NSMutableDictionary alloc] initWithCapacity:10];
    

    [self getCityList];
    
    //connecting to FB
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.facebook.sessionDelegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"FriendsPicstures"])
    {
        
        NSLog(@"pictures found in cache");
        self.friendPictures = [defaults objectForKey:@"FriendsPicstures"];
    }
    else
    {
        NSLog(@"pictures not in cache");
    }
    
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        delegate.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        NSLog(@"access token is : %@",delegate.facebook.accessToken);
        delegate.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![delegate.facebook isSessionValid])
    {
        
        NSArray *params = [[NSArray alloc] initWithObjects:@"user_location",@"friends_location",nil];
        
        if (![delegate.facebook isSessionValid])
        {
            NSLog(@"session invalid. authorising");
            [delegate.facebook authorize:params];
            
        }
        else
        {
            NSLog(@"session valid. fetching data.");
            currentAction = FETCHING_FRIENDS;
            [self getFacebookLocations];
        }
        
        
    }
    else
    {
        currentAction = FETCHING_FRIENDS;
        [self getFacebookLocations];
        
    }
    
//    self.citySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.citySearchBar.frame.size.width, self.citySearchBar.frame.size.height)];
    
//    [self.view addSubview:self.citySearchBar];
    
    

    [self.view addSubview:self.activity];
    
    

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
    
    self.activity.hidden = NO;
    [self.activity startAnimating];
    

        

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
    
    
   
    NSLog(@"parsed data : %@",jsonData);
    
    //NSArray *lcityList = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"place"];
    
    NSDictionary *item = [[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"] objectForKey:@"item"];
    
    NSString *title = [[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"] objectForKey:@"title"];
    
    [self.tableData removeAllObjects];
    [self.tableDataSections removeAllObjects];
    
    if(![title compare:@"Yahoo! Weather - Error"])
    {
        NSLog(@"weather info not found");
        [self.tableDataSections addObject:@"Weather NA"];
        [tableDataElement removeAllObjects];
        [tableDataElement addObject:@"Not available :("];
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
        
        NSLog(@"today weather");
        
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
//            NSLog(@"temp : %u and climate : %@", temperature, climate);
      }
        
        
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
    
        NSLog(@"weather info found");
        [self.tableDataSections addObject:@"Weather"];
//        [tableDataElement removeAllObjects];
        //[tableDataElement addObject:@"not available"];
//        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
        
    }
    
    //    NSLog(@"week info : %@", [item objectForKey:@"forecast"]);
    
    
    NSLog(@"sections : %@", self.tableDataSections);
    //    NSLog(@"table data : %@",self.tableData);
    
    NSLog(@"table data element : %@", tableDataElement);
    
    //get cab info
    
    [self gatherCabInfo:city];
    
    //Hospitals
    
    [self gatherHospitalInfo:city];
    
    //hotels
    
    [self gatherHotelInfo:city];
    
    //fetching near facebook friend
    
    [self gatherFacebookInfo:woeid];
    
    

    
    iCityShowCityInfo *cityInfo = [[iCityShowCityInfo alloc] init];
    
    cityInfo.rowArray = [NSArray arrayWithArray:self.tableData];
    cityInfo.sectionArray = [NSArray arrayWithArray:self.tableDataSections];
    cityInfo.title = city;
    
    cityInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelthis)];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:cityInfo];
    
    self.navController.toolbarHidden = NO;
    self.navController.hidesBottomBarWhenPushed = YES;
    
    
        
        [self.activity stopAnimating];
        self.activity.hidden = YES;
        [self presentViewController:navController animated:YES completion:nil];
    
    
}

-(void)gatherHotelInfo:(NSString*)city
{
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSLog(@"hospital from city %@", city);
    NSData *hotelData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[HOTEL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]];
    
    NSLog(@"query for hospital : %@", [NSURL URLWithString:[HOTEL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:hotelData options:kNilOptions error:&error];
    
    NSLog(@"hospital data : %@",jsonData);
    
    NSArray *hospitalArray = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"results"];
    
    
    for(NSDictionary *hotel in hospitalArray)
        
    {
        
        [tableDataElement addObject:hotel];
    }
    
    
    [self.tableDataSections addObject:@"Hotels & Restaurants" ];
    
    if(tableDataElement.count)
    {
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
    }
    

    
    
}

-(void)gatherHospitalInfo:(NSString*)city
{
    
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSLog(@"hospital from city %@", city);
    NSData *hospitalData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[HOSPITAL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]];
    
    NSLog(@"query for hospital : %@", [NSURL URLWithString:[HOSPITAL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:hospitalData options:kNilOptions error:&error];
    
    NSLog(@"hospital data : %@",jsonData);
    
    NSArray *hospitalArray = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"results"];


    for(NSDictionary *hospital in hospitalArray)
    
    {
    
        [tableDataElement addObject:hospital];
    }
    
    
    [self.tableDataSections addObject:@"Hospitals" ];
    
    if(tableDataElement.count)
    {
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
    }


}

-(void)gatherCabInfo:(NSString*)city
{
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSLog(@"cab url : %@", [NSURL URLWithString:[GOOGLE_API stringByAppendingFormat:@"%@+cabs",city]]);
    
    NSData *cabData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[GOOGLE_API stringByAppendingFormat:@"%@+cabs",city]]];
    
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:cabData options:kNilOptions error:&error];
    
    NSLog(@"cab data : %@", [[jsonData objectForKey:@"responseData"] objectForKey:@"results"]);
    
    NSArray *cabArray = [[jsonData objectForKey:@"responseData"] objectForKey:@"results"];
    
    for(NSDictionary *cab in cabArray)
    {
        [tableDataElement addObject:cab];
    }
    
    [self.tableDataSections addObject:@"Taxi"];
    
    if(tableDataElement.count)
    {
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
        
    }
    
}


-(void)fbDidLogin
{
    NSLog(@"in fbdidlogin");
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[delegate.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[delegate.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    if ([delegate.facebook isSessionValid])
    {
        NSLog(@"already logged in");
        NSLog(@"checking permissons");
        
        currentAction = FETCHING_FRIENDS;
        
        [self getFacebookLocations];
        
    }
    
    
}

-(void)getFacebookLocations
{
    currentAction = FETCHING_FRIENDS;
    
    NSLog(@"calling getFacebookLocations");
    
    iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    
    NSString *userQuery = @"select uid, name , current_location, pic_square from user where uid in (select uid2 from friend where uid1=me()) order by name";
    
//    NSString *userQuery = @"select uid, name , current_location, pic_square from user where uid in (100003654619523,100000843410725) order by name";
    
    
    NSMutableDictionary *queryParam =[NSMutableDictionary dictionaryWithObjectsAndKeys:userQuery, @"query", nil];
    
    [appDelegate.facebook requestWithMethodName:@"fql.query" andParams:queryParam andHttpMethod:@"POST" andDelegate:self];
    
}

-(void)request:(FBRequest *)request didLoad:(id)result
{
    
    iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary *cityToFriendMapping = [[NSMutableDictionary alloc] initWithCapacity:AVERAGE_FRIENDS];
    NSMutableDictionary *cityGeoLocationMapping = [[NSMutableDictionary alloc] initWithCapacity:AVERAGE_FRIENDS];
    NSMutableDictionary *cityGeoNameMapping = [[NSMutableDictionary alloc] initWithCapacity:AVERAGE_FRIENDS];
    NSMutableDictionary *cityGeoPictureMapping = [[NSMutableDictionary alloc] initWithCapacity:AVERAGE_FRIENDS];
    NSMutableArray *cityFriendDictionaryArray = [[NSMutableArray alloc] initWithCapacity:AVERAGE_FRIENDS];
    
    
    if(currentAction == FETCHING_FRIENDS)
    {
        NSMutableString *locationQuery = [NSMutableString stringWithString:@"select page_id, pic_square, name , latitude , longitude from place where page_id in ( "];
        
        if(result)
        {
            NSArray *resultData = (NSArray *)result;
            NSLog(@"Fetched objects = %u",[resultData count]);
            //NSLog(@"result of friends = %@",resultData);
            
            int cacheflag=0;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (![defaults objectForKey:@"FriendsPicstures"])
            {
                cacheflag = 1;
            }
            
            if([resultData count]>0)
            {
                
                //creating FOMFriendDetails friend objects and
                for (NSDictionary *data in resultData)
                {
                    iCityFriendDetails *friend = [[iCityFriendDetails alloc] init];
                    
                    friend.name = [data objectForKey:@"name"];
                    friend.small_pic = [NSURL URLWithString:[data objectForKey:@"pic_square"]];
                    friend.userID = [data objectForKey:@"uid"];
                    
//                    if(cacheflag)
//                    {
//                        UIImage *friendImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:friend.small_pic]];
//                        NSData *friendImageData = [NSKeyedArchiver archivedDataWithRootObject:friendImage];
//
//
//                        [self.friendPictures setObject:friendImageData forKey:friend.userID];
//                        
//                        NSLog(@"friend %@ processed", friend.name);
//                    }
                    
                    //getting frineds current location details
                    NSDictionary *currentlocation = [(NSDictionary *)data objectForKey:@"current_location"];
                    if(! ((NSNull*)currentlocation == [NSNull null]) )
                    {
                        friend.currentCity = [currentlocation objectForKey:@"name"];
                        friend.cityID = [currentlocation objectForKey:@"id"];
                        
                        if([friend.currentCity length]>0 && friend.cityID !=nil )
                        {
                            //adding friend in array of respective dictionary of cityID
                            if([cityToFriendMapping objectForKey:friend.cityID] == nil)
                            {
                                NSMutableArray *friendArray = [[NSMutableArray alloc] initWithObjects:friend, nil];
                                [cityToFriendMapping setObject:friendArray forKey:friend.cityID];
                                
                            }
                            else
                            {
                                NSMutableArray *friendArray = [[cityToFriendMapping objectForKey:friend.cityID] mutableCopy];
                                [friendArray addObject:friend];
                                [cityToFriendMapping setObject:friendArray forKey:friend.cityID];
                                
                            }
                        }
                        else
                        {
                            //                            NSLog(@"%@",[friend.name stringByAppendingString:@" has no city ID %@"]);
                            
                        }
                    }
                    else
                    {
                        //                        NSLog(@"%@",[friend.name stringByAppendingString:@" has no city ID %@"]);
                        
                    }
                    
                }
                
            }
            
            if(cacheflag)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                [defaults setObject:[NSDictionary dictionaryWithDictionary:self.friendPictures] forKey:@"FriendsPicstures"];
                [defaults synchronize];
                NSLog(@"pictured saved in cache");
                
            }
            
            
            //here we have dictionary of cityID and all friends into that city
            NSLog(@"Total cities: %u", [cityToFriendMapping count]);
            
            //            dispatch_async( dispatch_get_main_queue(), ^{
            //
            //
            //            });
            
            self.cityToFriendMappingG = [[NSMutableDictionary alloc] initWithDictionary:cityToFriendMapping];
            
            
            //finding cityID details like latitude and longitude
            NSArray *allLocationIDs = [cityToFriendMapping allKeys];
            
            if(allLocationIDs.count)
            {
                //generating query to fetch location data
                if([allLocationIDs count] > 1)
                {
                    [locationQuery appendFormat:@"%@",[allLocationIDs objectAtIndex:0]];
                    
                    for(int index=1; index < [allLocationIDs count]; index++)
                    {
                        [locationQuery appendFormat:@",%@",[allLocationIDs objectAtIndex:index]];
                        
                    }
                    [locationQuery appendString:@")"];
                    
                }
                else
                {
                    [locationQuery appendFormat:@"%@ )",[allLocationIDs objectAtIndex:0]];
                }
                
                
                NSMutableDictionary *queryParam =[NSMutableDictionary dictionaryWithObjectsAndKeys:locationQuery, @"query", nil];
                
                currentAction = FETCHING_CITIES;
                
                [appDelegate.facebook requestWithMethodName:@"fql.query" andParams:queryParam andHttpMethod:@"POST" andDelegate:self];
                
                
            }
            
            
        }
        
        
        
    }
    else if (currentAction == FETCHING_CITIES)
    {
        
        if(result)
        {
            NSArray *cityData = (NSArray *)result;
            
            
            //NSLog(@"%@",cityData);
            
            for(NSDictionary *place in cityData)
            {
                CLLocationDegrees latitude = [(NSString*)[place objectForKey:LATITUDE] doubleValue];
                CLLocationDegrees longitude = [(NSString*)[place objectForKey:LONGITUDE] doubleValue];
                //NSString *city= (NSString*)[place objectForKey:@"name"];
                CLLocationCoordinate2D location;
                location.latitude = latitude;
                location.longitude = longitude;
                
                NSData *locationIntoData = [NSData dataWithBytes:&location length:sizeof(location)];
                
                NSString *locationID = (NSString*)[place objectForKey:@"page_id"];
                NSURL *cityPic = [NSURL URLWithString:(NSString*)[place objectForKey:@"pic_square"]];
                
                NSString *cityName = (NSString*)[place objectForKey:@"name"];
                
                [cityGeoLocationMapping setObject:locationIntoData forKey:locationID];
                [cityGeoPictureMapping setObject:cityPic forKey:locationID];
                [cityGeoNameMapping setObject:cityName forKey:locationID];
                
                
                
                //NSLog(@"%@ is at %f, %f", city, latitude, longitude);
                
            }
            
            NSLog(@"%u cities fetched",[cityGeoLocationMapping count]);
            
            NSLog(@"%u friends are there",[self.cityToFriendMappingG count]);
            
            cityToFriendMapping = [[NSMutableDictionary alloc] initWithDictionary:self.cityToFriendMappingG];
            
            NSLog(@"%u friends in local array are there",[cityToFriendMapping count]);
            
            
            //mapping location to friends and geo locations and adding them into array
            
            for(NSString *cityID in [cityGeoLocationMapping allKeys])
            {
                NSMutableDictionary *friendWithLocation = [[NSMutableDictionary alloc] initWithCapacity:AVERAGE_FRIENDS];
                
                
                [friendWithLocation setObject:(NSData*)[cityGeoLocationMapping objectForKey:cityID] forKey:LOCATION_DATA];
                
                [friendWithLocation setObject:(NSArray*)[cityToFriendMapping objectForKey:cityID] forKey:FRIEND_DATA];
                
                [friendWithLocation setObject:cityID forKey:CITY_ID];
                [friendWithLocation setObject:(NSURL*)[cityGeoPictureMapping objectForKey:cityID] forKey:CITY_PIC];
                [friendWithLocation setObject:(NSURL*)[cityGeoNameMapping objectForKey:cityID] forKey:@"city_name"];
                
                
                [cityFriendDictionaryArray addObject:friendWithLocation];
                
            }
            
            self.cityFriendDictionaryArrayG = [[NSMutableArray alloc] initWithArray:cityFriendDictionaryArray];
            
            NSLog(@"%u is size of array",[cityFriendDictionaryArray count]);
            
            
            
        }
        
    }
    
    
    
}

-(void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"fb login failed");
}

-(void)gatherFacebookInfo:(NSString*)woeid
{
    
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSLog(@"url : %@", [NSURL URLWithString:[LOCATION_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]] );
    
    NSData *locationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[LOCATION_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]]];
    
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:locationData options:kNilOptions error:&error];
    
    //NSLog(@"parsed data for location: %@",jsonData);
    
    NSInteger longitude = [[[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"Result"] objectForKey:@"longitude"] doubleValue]*1000;
    
    
    
    NSInteger latitude = [[[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"Result"] objectForKey:@"latitude"] doubleValue]*1000;
    
    NSLog(@"location : %ld %ld", (long)latitude  , (long)longitude);
    
    
    //    NSLog(@"cityFriendDictionaryArrayG = %@", self.cityFriendDictionaryArrayG);
    //    NSLog(@"cityToFriendMappingG = %@", self.cityToFriendMappingG);
    
    NSLog(@"cityFriendDictionaryArrayG count : %u", self.cityFriendDictionaryArrayG.count);
    
    [tableDataElement removeAllObjects];
    [self.tableDataSections addObject:@"Facebook Friends Nearby"];
    
    for(NSDictionary *tmpCity in self.cityFriendDictionaryArrayG)
    {
        NSData *locationDetails = [tmpCity objectForKey:LOCATION_DATA];
        
        CLLocationCoordinate2D location;
        [locationDetails getBytes:&location];
        
        NSInteger tmpLongitude = location.longitude*1000;
        NSInteger tmpLatitude = location.latitude*1000;
        
        //        NSLog(@"%@ has %u %u, %u %u", [tmpCity objectForKey:@"city_name"], tmpLatitude, latitude, tmpLongitude, longitude);
        
        //NSLog(@"%u %u",tmpLatitude, latitude);
        
        if ( (tmpLatitude >= latitude-300 && tmpLatitude <= latitude+300) && (tmpLongitude >= longitude-500 && tmpLongitude <= longitude+500))
        {
            //            NSLog(@"inside if");
            
            NSArray *friendData = [tmpCity objectForKey:FRIEND_DATA];
            
            for(iCityFriendDetails *friend in friendData)
            {
                //                NSLog(@"%@ lives nearby", friend.name);
                
//                UIImage *image = [UIImage imageNamed:@"697059692.jpg"];
                
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",[friend userID]]];
                
//                NSLog(@"image = %@",[NSString stringWithFormat:@"%@.jpg",[friend userID]]);
                
//                NSLog(@"imagedata=%@",image);
                
                
                if(!image)
                {
                    image = [UIImage imageNamed:@"dummy.gif"];
                }
                
                
                NSDictionary *friendRow = [[NSDictionary alloc] initWithObjectsAndKeys:friend.name,@"name",image,@"small_pic", nil];
                
                [tableDataElement addObject:friendRow];
                
                
            }
            
            
        }
        
    }
    
    if(tableDataElement.count)
    {
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
    }
    else
    {
        [self.tableData addObject:[NSArray arrayWithObject:@"No friend nearby"]];
    }
    
    
}






@end
