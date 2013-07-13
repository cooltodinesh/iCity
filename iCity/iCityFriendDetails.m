//
//  iCityFriendDetails.m
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityFriendDetails.h"

@implementation iCityFriendDetails

@synthesize name = _name;
@synthesize cityID = _cityID;
@synthesize currentCity = _currentCity;
@synthesize small_pic = _small_pic;
@synthesize userID = _userID;

CLLocationDegrees latitude;
CLLocationDegrees longitude;

-(void)setLatitude:(CLLocationDegrees)newLatitude
{
    latitude = newLatitude;
}

-(CLLocationDegrees)getLatitude
{
    return latitude;
}


-(void)setLongitude:(CLLocationDegrees)newLongitude
{
    longitude = newLongitude;
}

-(CLLocationDegrees)getLongitude
{
    return longitude;
}

@end
