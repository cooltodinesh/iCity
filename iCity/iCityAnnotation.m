//
//  iCityAnnotation.m
//  iCity
//
//  Created by Dinesh Salve on 21/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityAnnotation.h"

@implementation iCityAnnotation

@synthesize userAnnotation;

+ (iCityAnnotation*)annotationForUser:(NSDictionary *)userAnnotation
{
    
    iCityAnnotation *annotation = [[iCityAnnotation alloc] init];
    annotation.userAnnotation = userAnnotation;
    return annotation;
}

-(NSString*)title
{
    return [self.userAnnotation objectForKey:@"county"];
}

//-(NSString*)subtitle
//{
//    return [self.userAnnotation objectForKey:FRIEND_CITY];
//}

-(CLLocationCoordinate2D) coordinate
{
    
    NSData *locationDetails = [self.userAnnotation objectForKey:@"location"];
    
    CLLocationCoordinate2D coordinate;
    
    [locationDetails getBytes:&coordinate];
    
    return coordinate;
}

-(NSString*)woeid
{
    return [self.userAnnotation objectForKey:@"woeid"];
}



@end
