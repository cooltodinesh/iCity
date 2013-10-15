//
//  iCityDataFetcher.m
//  iCity
//
//  Created by Dinesh Salve on 19/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityDataFetcher.h"
#import "iCityTableViewConroller.h"
#include <CoreLocation/CoreLocation.h>
#import "iCityMapViewController.h"
#import "iCityAppDelegate.h"


#define ALL_CITY_INFO @"http://query.yahooapis.com/v1/public/yql?q=select%20county%2C%20longitude%2C%20latitude%2C%20woeid%20from%20geo.placefinder%20where%20woeid%20in%20(select%20woeid%20from%20geo.counties%20where%20place%20%3D%20%22IN%22)&format=json"

@implementation iCityDataFetcher

@synthesize cityDictionary, cityList, allCityInfo;

-(void)parseTaxiNumber
{

    iCityAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSString *taxiFilePath = [[NSBundle mainBundle] pathForResource:@"Taxi" ofType:@"txt"];
    NSData *taxiData = [NSData dataWithContentsOfFile:taxiFilePath];
    NSError *error;
    NSDictionary *taxijsonData = [NSJSONSerialization JSONObjectWithData:taxiData options:kNilOptions error:&error];
//    NSLog(@"taxi data : %@",taxijsonData);
    
    NSDictionary *allCities = [taxijsonData objectForKey:@"result"];
    
    delegate.allCityTaxiNumber = allCities;
    
//    NSLog(@"Guwahati - meru number : %@", [[[[allCities objectForKey:@"Hyderabad"] objectAtIndex:4] objectForKey:@"number"] objectAtIndex:0]);
    
//    NSLog(@"URL found %@", [[[allCities objectForKey:@"Guwahati"] objectAtIndex:1] objectForKey:@"url"]);
    
//    if( [[[[allCities objectForKey:@"Guwahati"] objectAtIndex:5] objectForKey:@"url"] isKindOfClass:[NSNull class]] )
//    {
//        NSLog(@"No url found");
//    }
//    else
//    {
//        NSLog(@"URL found %@", [[[allCities objectForKey:@"Guwahati"] objectAtIndex:5] objectForKey:@"url"]);
//    }
//    
//    if( [[[[allCities objectForKey:@"Guwahati"] objectAtIndex:1] objectForKey:@"url"] isKindOfClass:[NSNull class]] )
//    {
//        
//        NSLog(@"No url found");        
//
//    }
//    else
//    {
//                NSLog(@"URL found %@", [[[allCities objectForKey:@"Guwahati"] objectAtIndex:1] objectForKey:@"url"]);
//
//    }
//    

    
}

-(void)getCityList:(iCityTableViewConroller*)tableView
{
    
    [self parseTaxiNumber];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"iCityData" ofType:@"txt"];

    
    if(!self.cityList)
    {
        //{"latitude":"19.44916","longitude":"83.449135","county":"Rayagada","woeid":"12586623"}
        
        NSData *cityData = [NSData dataWithContentsOfFile:filePath];
        
        //NSLog(@"raw data : %@",cityData);
        
        NSError *error;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:&error];
        
        //    NSLog(@"parsed data : %@",jsonData);
        
        NSArray *lcityList = [[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"Result"];
        
        //    NSLog(@"state list : %@",[[[[[jsonData objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"place"] objectAtIndex:0] objectForKey:@"name"]);
        
        NSMutableDictionary *lcityDictionary = [[NSMutableDictionary alloc] initWithCapacity:100];
        NSMutableArray *tmpcityList = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *lAllCityInfo = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableDictionary *stateDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        
        for(NSDictionary *city in lcityList)
        {
            //NSLog(@"%@ - %@",[city objectForKey:@"name"], [city objectForKey:@"woeid"]);
            
//            NSLog(@"city is : %@", city);
            
            [lcityDictionary setObject:[city objectForKey:@"woeid"] forKey:[city objectForKey:@"county"]];
            
            [stateDictionary setObject:[city objectForKey:@"state"] forKey:[city objectForKey:@"county"]];
            
            [tmpcityList addObject:[city objectForKey:@"county"]];
            
            CLLocationDegrees latitude = [(NSString*)[city objectForKey:@"latitude"] doubleValue];
            CLLocationDegrees longitude = [(NSString*)[city objectForKey:@"longitude"] doubleValue];
            //NSString *city= (NSString*)[place objectForKey:@"name"];
            CLLocationCoordinate2D location;
            location.latitude = latitude;
            location.longitude = longitude;
            
            NSData *locationIntoData = [NSData dataWithBytes:&location length:sizeof(location)];
            
            NSDictionary *tmpAllCityInfo = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[city objectForKey:@"county"],[city objectForKey:@"woeid"],locationIntoData, nil] forKeys:[NSArray arrayWithObjects:@"county",@"woeid",@"location" ,nil]];
            
            [lAllCityInfo addObject:tmpAllCityInfo];
        
            
        }
        
        //NSLog(@"%@",cityDictionary);
        
        
        self.cityList = [NSArray arrayWithArray:[tmpcityList sortedArrayUsingComparator:^(NSString* a, NSString* b) {
            return [a compare:b options:NSNumericSearch];
        }]];
        
        self.cityDictionary = lcityDictionary;
        //    self.cityList = tmpcityList;
        
        //});
        
        self.allCityInfo = lAllCityInfo;
        tableView.stateDictionary = stateDictionary;
        
        
    }
    
    tableView.cityList = self.cityList;
    tableView.cityDictionary = self.cityDictionary;
    
    
       
}

-(void)getAllAnnotations:(iCityMapViewController*)mapView
{
    mapView.allCityInfo = self.allCityInfo;
    
    NSLog(@"setting all city count %u", self.allCityInfo.count);
    
}




@end
