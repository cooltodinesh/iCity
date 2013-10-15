//
//  iCityProcessor.m
//  iCity
//
//  Created by Dinesh Salve on 23/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityProcessor.h"
#import "iCityMapViewController.h"
#import "iCityTableViewConroller.h"
#import "iCityAppDelegate.h"
#import "iCityFriendDetails.h"
#import "iCityShowCityInfo.h"
#include <arpa/inet.h>

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

@interface iCityProcessor()

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *tableDataSections;

@end


@implementation iCityProcessor

@synthesize citywoeid, tableData, tableDataSections, caller;

-(void)processCity:(NSString *)city
{
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    BOOL connected = [delegate isInternetConnected];
    

    [delegate.tracker sendEventWithCategory:@"CitySearched" withAction:@"CitySearched" withLabel:city withValue:[NSNumber numberWithInt:1]];
    
//
//    delegate.mainView.activity.hidden = NO;
//    [delegate.mainView.activity startAnimating];
    
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableDataSections = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSString *woeid = self.citywoeid;
    
    NSLog(@"woeid is : %@",woeid);
    
    if(connected)
    {
        NSData *weatherData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[WEATHER_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]]];
        
//        NSLog(@"weather url : %@",[WEATHER_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]);
        
//        NSLog(@"query for weather : %@", [NSURL URLWithString:[WEATHER_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]]);
        
        NSError *error;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
        
        
//        NSLog(@"parsed data : %@",jsonData);
        
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
            
            
            [tableDataElement addObject:todayWeather];
            
//            NSLog(@"today weather");
            
            
            //weekly weather
            
            
            NSMutableArray *weekWeather = [[item objectForKey:@"forecast"] mutableCopy];
            [weekWeather removeObjectAtIndex:0];
            
            for(NSDictionary *weekday in weekWeather)
            {
                
                NSDictionary *todayWeather = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%u-%u", ([[weekday objectForKey:@"low"] integerValue]-32)*5/9, ([[weekday objectForKey:@"high"] integerValue]-32)*5/9],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"text"]],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"day"]] ,nil] forKeys:[NSArray arrayWithObjects:@"temperature",@"climate",@"day", nil]];
                
                
                [tableDataElement addObject:todayWeather];
                
                
            }
            
            
            [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
            
            NSLog(@"weather info found");
            [self.tableDataSections addObject:@"Weather"];
            
            
            
        }
        
        
        
//        NSLog(@"sections : %@", self.tableDataSections);
        //    NSLog(@"table data : %@",self.tableData);
        
//        NSLog(@"table data element : %@", tableDataElement);
        
        //get cab info
        
        [self gatherCabInfo:[city stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
        //Hospitals
        
        [self gatherHospitalInfo:[city stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
        //hotels
        
        [self gatherHotelInfo:[city stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
    //    [self gatherHospitalInfoFromGoogle:[city stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    //    [self gatherHotelInfoFromGoogle:[city stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
        //fetching near facebook friend
        
        [self gatherFacebookInfo:woeid andCity:city];
    }
    else if (!connected)
    {
        
//        NSLog(@"weather info not found");
        [self.tableDataSections addObject:@"Weather NA"];
        [tableDataElement removeAllObjects];
        [tableDataElement addObject:@"Not available :("];
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
        
        if( [delegate.allCityTaxiNumber objectForKey:city] )
        {
            
//            NSLog(@"fetching data from taxi number dictionary");
            
            NSArray *cabList = [delegate.allCityTaxiNumber objectForKey:city];
            NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithArray:cabList];
            [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
            [self.tableDataSections addObject:@"Taxi"];
            
        }
        
        dispatch_sync(dispatch_get_main_queue(),^{

            delegate.mainView.tableDataSections = self.tableDataSections;
            
            delegate.mainView.tableData = self.tableData;
            
//            NSLog(@"presenting city from processor");
            
            [delegate.mainView presentCity];
            
        });
        
    }
    
}



-(void)gatherHotelInfoFromGoogle:(NSString*)city
{
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
//    NSLog(@"hotel from city %@", city);
    NSData *hospitalData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[GOOGLE_API stringByAppendingFormat:@"%@+top+hotels",city]]];
    
//    NSLog(@"hotel URL : %@", [GOOGLE_API stringByAppendingFormat:@"%@+top+hotels",city]);
    
//    NSLog(@"hotel data %@: ",hospitalData);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:hospitalData options:kNilOptions error:&error];
    
    //    NSLog(@"cab data : %@", [[jsonData objectForKey:@"responseData"] objectForKey:@"results"]);
    
    
    
//    NSLog(@"hotel data %@: ",jsonData);
    
    if ( ! [[jsonData objectForKey:@"responseData"]  isKindOfClass:[NSNull class]])
    {
        NSArray *hospitalArray = [[jsonData objectForKey:@"responseData"] objectForKey:@"results"];
    
        if ( ! [hospitalArray isKindOfClass:[NSNull class]])
        {
            for(NSDictionary *hotel in hospitalArray)
            {
                NSDictionary *hospitalData = [[NSDictionary alloc] initWithObjectsAndKeys:[hotel objectForKey:@"titleNoFormatting"],@"titleNoFormatting",[hotel objectForKey:@"url"],@"url", nil];
                
                [tableDataElement addObject:hospitalData];
            }
            
            
            if(tableDataElement.count)
            {
                [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
                
            }
            
            
            [self.tableDataSections addObject:@"Hotels"];
        }
    }
    
}

-(void)gatherHotelInfo:(NSString*)city
{
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
//    NSLog(@"hotel from city %@", city);
    NSData *hotelData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[HOTEL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]];
    
//    NSLog(@"query for hotel : %@", [NSURL URLWithString:[HOTEL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:hotelData options:kNilOptions error:&error];
    
//    NSLog(@"hotel data : %@",jsonData);
    
    if( ! [[[jsonData objectForKey:@"query"] objectForKey:@"results"] isKindOfClass:[NSNull class]])
    {
//        NSLog(@"hotel data found");
        
        NSArray *hospitalArray = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"results"];
        
        
        for(NSDictionary *hotel in hospitalArray)
            
        {
            
            [tableDataElement addObject:hotel];
        }        
        
        [self.tableDataSections addObject:@"Hotels" ];
        
        if(tableDataElement.count)
        {
            [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
        }
        
    }
    else
    {
//        [self gatherHotelInfoFromGoogle:city];
    }
    
}


-(void)gatherHospitalInfoFromGoogle:(NSString*)city
{
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
//    NSLog(@"hospital from city %@", city);
    NSData *hospitalData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[GOOGLE_API stringByAppendingFormat:@"%@+hospitals",city]]];
//    NSLog(@"hotel URL : %@", [GOOGLE_API stringByAppendingFormat:@"%@+hospitals",city]);
    
//    NSLog(@"hospital data %@: ",hospitalData);
    
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:hospitalData options:kNilOptions error:&error];
    
//    NSLog(@"hospital data %@: ",jsonData);
    
//    NSLog(@"cab data : %@", [[jsonData objectForKey:@"responseData"] objectForKey:@"results"]);
    
    
    if( ! [[jsonData objectForKey:@"responseData"]  isKindOfClass:[NSNull class]] )
    {
    
        NSArray *hospitalArray = [[jsonData objectForKey:@"responseData"] objectForKey:@"results"];
        
        if( ! [hospitalArray isKindOfClass:[NSNull class]] )
        {
            
            for(NSDictionary *hotel in hospitalArray)
            {
                NSDictionary *hospitalData = [[NSDictionary alloc] initWithObjectsAndKeys:[hotel objectForKey:@"titleNoFormatting"],@"titleNoFormatting",[hotel objectForKey:@"url"],@"url", nil];
                
                [tableDataElement addObject:hospitalData];
            }
            
            
            if(tableDataElement.count)
            {
                [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
                
            }


            [self.tableDataSections addObject:@"Hospitals"];
        }
    }
    

}

-(void)gatherHospitalInfo:(NSString*)city
{
    
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
//    NSLog(@"hospital from city %@", city);
    NSData *hospitalData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[HOSPITAL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]];
    
//    NSLog(@"query for hospital : %@", [NSURL URLWithString:[HOSPITAL_URL stringByReplacingOccurrencesOfString:@"AAAAAAAA" withString:city]]);
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:hospitalData options:kNilOptions error:&error];
    
//    NSLog(@"hospital data : %@",jsonData);
    
    if( ! [[[jsonData objectForKey:@"query"] objectForKey:@"results"] isKindOfClass:[NSNull class]])
    {
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
    else
    {
//        [self gatherHospitalInfoFromGoogle:city];
    }
    
}

-(void)gatherCabInfo:(NSString*)city
{
    iCityAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if( [delegate.allCityTaxiNumber objectForKey:city] )
    {
        
//        NSLog(@"fetching data from taxi number dictionary");
        
        NSArray *cabList = [delegate.allCityTaxiNumber objectForKey:city];
        NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithArray:cabList];
        [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
        [self.tableDataSections addObject:@"Taxi"];
        
    }
    else
    {
        
//        NSLog(@"querying google for cab data");
        
        
        NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
        
//        NSLog(@"city : %@", city);
//        NSLog(@"cab url : %@", [NSURL URLWithString:[GOOGLE_API stringByAppendingFormat:@"%@+taxi",city]]);

        
        NSData *cabData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[GOOGLE_API stringByAppendingFormat:@"%@+cabs",city]]];
        
        
        NSError *error;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:cabData options:kNilOptions error:&error];
        
        
        
        
        if ( ! [[jsonData objectForKey:@"responseData"] isKindOfClass:[NSNull class]] )
        {
            NSArray *cabArray = [[jsonData objectForKey:@"responseData"] objectForKey:@"results"];
//            NSLog(@"cab data : %@", cabArray);
        
            if ( ! [cabArray isKindOfClass:[NSNull class]] )
            {
            
                for(NSDictionary *cab in cabArray)
                {
                    NSDictionary *cabData = [[NSDictionary alloc] initWithObjectsAndKeys:[cab objectForKey:@"titleNoFormatting"],@"cabname",[cab objectForKey:@"url"],@"url", nil];
                    
                    [tableDataElement addObject:cabData];
                }
                
                
                if(tableDataElement.count)
                {
                    [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
                    [self.tableDataSections addObject:@"Taxi"];
                    
                }
            }
        }
    }
    
    
    
}


-(void)gatherFacebookInfo:(NSString*)woeid andCity:(NSString*)city
{
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray *tableDataElement = [[NSMutableArray alloc] initWithCapacity:10];
    
//    NSLog(@"url : %@", [NSURL URLWithString:[LOCATION_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]] );
    
    NSData *locationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[LOCATION_URL stringByReplacingOccurrencesOfString:@"00000000" withString:woeid]]];
    
    
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:locationData options:kNilOptions error:&error];
    
    //NSLog(@"parsed data for location: %@",jsonData);
    
    NSInteger longitude = [[[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"Result"] objectForKey:@"longitude"] doubleValue]*1000;
    
    
    
    NSInteger latitude = [[[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"Result"] objectForKey:@"latitude"] doubleValue]*1000;
    
//    NSLog(@"location : %ld %ld", (long)latitude  , (long)longitude);
    
    NSArray *cityFriendDictionaryArrayG = [NSArray arrayWithArray:delegate.cityFriendDictionaryArrayG];
    
//    NSLog(@"cityFriendDictionaryArrayG count : %u", cityFriendDictionaryArrayG.count);
    
    [tableDataElement removeAllObjects];
    [self.tableDataSections addObject:@"Facebook Friends Nearby"];
    
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        
        [cityFriendDictionaryArrayG enumerateObjectsUsingBlock:^(NSDictionary *tmpCity, NSUInteger idx, BOOL *stop) {
            
            NSData *locationDetails = [tmpCity objectForKey:LOCATION_DATA];
            
            CLLocationCoordinate2D location;
            [locationDetails getBytes:&location];
            
            NSInteger tmpLongitude = location.longitude*1000;
            NSInteger tmpLatitude = location.latitude*1000;
            
            
            if ( (tmpLatitude >= latitude-300 && tmpLatitude <= latitude+300) && (tmpLongitude >= longitude-500 && tmpLongitude <= longitude+500))
            {
                
                NSArray *friendData = [tmpCity objectForKey:FRIEND_DATA];
                
                for(iCityFriendDetails *friend in friendData)
                {
                    
                    
//                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",[friend userID]]];
                    
//                    UIImageView *imageView = [[UIImageView alloc]init];
//                    
//                    [imageView setImageWithURL:friend.small_pic placeholder:[UIImage imageNamed:@"dummy.gif"]];
//                    
//                    image = imageView.image;
//                    
//                    if(!image)
//                    {
//                        image = [UIImage imageNamed:@"dummy.gif"];
//                    }
//                    
                    
                    NSDictionary *friendRow = [[NSDictionary alloc] initWithObjectsAndKeys:friend.name,@"name",friend.small_pic,@"small_pic", nil];
                    
                    [tableDataElement addObject:friendRow];
                    
//                    NSLog(@"%@ processed", friend.name);
                    
                }
                
            }
            
        }];
        
        dispatch_sync(dispatch_get_main_queue(),^{
            
            
            if(tableDataElement.count)
            {
                [self.tableData addObject:[NSArray arrayWithArray:tableDataElement]];
            }
            else
            {
                [self.tableData addObject:[NSArray arrayWithObject:@"No friend nearby"]];
            }
            
            iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            appDelegate.mainView.tableDataSections = self.tableDataSections;
            
            appDelegate.mainView.tableData = self.tableData;

//            NSLog(@"presenting city from processor");
            
            [appDelegate.mainView presentCity];
            
            
        });
        
        
//    });
    
}

@end
