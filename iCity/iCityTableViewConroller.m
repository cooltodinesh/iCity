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
#import "iCityDataFetcher.h"
#import "iCityProcessor.h"
#import "iCityMainViewController.h"

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



@interface iCityTableViewConroller () <FBSessionDelegate, FBRequestDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    int currentAction;

}

//@property (strong, nonatomic) IBOutlet UISearchBar *citySearchBar;


@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) NSString *cityname;

@property (strong, nonatomic) NSMutableDictionary *cityToFriendMappingG;

@property (strong, nonatomic) NSMutableArray *cityFriendDictionaryArrayG;

@property (strong, nonatomic) NSMutableDictionary *friendPictures;


@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation iCityTableViewConroller

@synthesize citySearchList, cityList, cityDictionary, tableData, tableDataSections, navController, cityFriendDictionaryArrayG, cityToFriendMappingG, friendPictures, cityname, mainView, stateDictionary, searchBar;


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect rect = self.searchBar.frame;
    rect.origin.y = MIN(0, scrollView.contentOffset.y);
    
    self.searchBar.frame = rect;
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"touched search bar");
    
//    NSLog(@"search bar delegate : %@", self.searchBar.delegate);
    
    [self pushDividerBarDown];
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"scrolling table");

    [self pushDividerBarDown];

}

-(void)pushDividerBarDown
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    
    self.mainView.barView.frame = CGRectMake(0, [self.mainView screenHeight ] -100, [self.mainView screenWidth ], 12);
    
    self.mainView.cityView.view.frame = CGRectMake(0, 0, [self.mainView screenWidth ], self.mainView.barView.frame.origin.y - 1 );
    
    self.mainView.mapView.view.frame = CGRectMake(0, self.mainView.barView.frame.origin.y+12 , [self.mainView screenWidth ], [self.mainView screenHeight ] - self.mainView.barView.frame.origin.y+12);
    
    [UIView commitAnimations];
    

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, [self.mainView screenWidth], searchBar.frame.size.height)];
    
    self.searchBar.delegate = self;
    
        
    self.cityToFriendMappingG = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.cityFriendDictionaryArrayG  = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableDataSections = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.friendPictures = [[NSMutableDictionary alloc] initWithCapacity:10];
    
//    self.searchDisplayController.delegate = self;
    self.tableView.delegate = self;
    
    //connecting to FB
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.facebook.sessionDelegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    
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
    
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF beginswith[c] %@",
                                    searchText];
    
    self.citySearchList = [self.cityList filteredArrayUsingPredicate:resultPredicate];
    
//    NSLog(@"new search list : %@ created from %u objects", self.citySearchList , self.cityList.count);
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
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        
    }
    
    
    // Configure the cell...
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
//        cell.textLabel.text = [self.citySearchList objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.citySearchList objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.stateDictionary objectForKey:[self.citySearchList objectAtIndex:indexPath.row]];
    }
    else
    {
//        cell.textLabel.text = [self.cityList objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.cityList objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.stateDictionary objectForKey:[self.cityList objectAtIndex:indexPath.row]];
        
    }
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *city;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        //        NSLog(@"%@ selected", [self.citySearchList objectAtIndex:indexPath.row]); UIView
        
        city = [[NSString alloc] initWithString:[self.citySearchList objectAtIndex:indexPath.row]];
        
        [self.searchBar resignFirstResponder];

        [tableView removeFromSuperview];
        
        [self.searchDisplayController setActive:NO animated:YES];
        
    }
    else
    {
        //        NSLog(@"%@ selected", [self.cityList objectAtIndex:indexPath.row]);
        
        city = [[NSString alloc] initWithString:[self.cityList objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"selected city : %@",city);
    
    self.cityname = city;
    
    
    iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.mainView.cityname = city;
    
    
//    appDelegate.mainView.activity.hidden = NO;
    
//    if( [appDelegate isInternetConnected] )
//    {
    
        [self.mainView willShowCity];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
            iCityProcessor *processor = [[iCityProcessor alloc] init];
            processor.citywoeid = [cityDictionary objectForKey:city];
            processor.caller = self;
            
            [processor processCity:self.cityname];
            
//            NSLog(@"calling processor");
        });
        
    //        [self processCity:city];
        
//    }
//    else
//    {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Error!!"
//                                                          message:@"No Internet connection found"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        [message show];
//    }

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
    
    iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    appDelegate.cityDictionary = self.cityDictionary;
    
    //});
    
    
}




-(void)cancelthis
{
//    NSLog(@"cancel in main view");
    [self.navController dismissViewControllerAnimated:YES completion:nil];
}





-(void)fbDidLogin
{
//    NSLog(@"in fbdidlogin");
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[delegate.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[delegate.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    if ([delegate.facebook isSessionValid])
    {
//        NSLog(@"already logged in");
//        NSLog(@"checking permissons");
        
        currentAction = FETCHING_FRIENDS;
        
        [self getFacebookLocations];
        
    }
    
    
}

-(void)getFacebookLocations
{
    
    if (self.cityFriendDictionaryArrayG.count < 1 )
    {
        
        currentAction = FETCHING_FRIENDS;
        
//        NSLog(@"calling getFacebookLocations");
        
        iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        
        
        NSString *userQuery = @"select uid, name , current_location, pic_square from user where uid in (select uid2 from friend where uid1=me()) order by name";
        
    //    NSString *userQuery = @"select uid, name , current_location, pic_square from user where uid in (100003654619523,100000843410725) order by name";
        
        
        NSMutableDictionary *queryParam =[NSMutableDictionary dictionaryWithObjectsAndKeys:userQuery, @"query", nil];
        
        [appDelegate.facebook requestWithMethodName:@"fql.query" andParams:queryParam andHttpMethod:@"POST" andDelegate:self];
        
    }
    
}

-(void)request:(FBRequest *)request didLoad:(id)result
{
    if (self.cityFriendDictionaryArrayG.count < 1 )
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
                
                appDelegate.cityFriendDictionaryArrayG = self.cityFriendDictionaryArrayG;
                appDelegate.cityToFriendMappingG = self.cityToFriendMappingG;
                
                NSLog(@"%u is size of array",[cityFriendDictionaryArray count]);
                
                
            }
            
        }
    
    }
    
}

-(void)fbDidNotLogin:(BOOL)cancelled
{
//    NSLog(@"fb login failed");
}





-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    
}

-(void)fbDidLogout
{
    
}

-(void)fbSessionInvalidated
{
    
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    
//    NSLog(@"in table view viewwillappear");
////    self.searchBar = [[UISearchBar alloc] init];
//    self.searchBar.delegate = self;
//    self.searchBar.userInteractionEnabled = YES;
//}
//
//- (BOOL)disablesAutomaticKeyboardDismissal {
//    return NO;
//}


@end
