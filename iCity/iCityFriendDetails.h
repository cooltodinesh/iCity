//
//  iCityFriendDetails.h
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface iCityFriendDetails : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *small_pic;
@property (strong, nonatomic) NSString *currentCity;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *cityID;


-(void)setLatitude:(CLLocationDegrees)newLatitude;
-(CLLocationDegrees)getLatitude;
-(void)setLongitude:(CLLocationDegrees)newLongitude;
-(CLLocationDegrees)getLongitude;


@end
