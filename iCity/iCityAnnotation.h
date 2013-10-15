//
//  iCityAnnotation.h
//  iCity
//
//  Created by Dinesh Salve on 21/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface iCityAnnotation : NSObject <MKAnnotation>

+(iCityAnnotation *)annotationForUser:(NSDictionary*)userAnnotation;

@property (strong, nonatomic) NSDictionary *userAnnotation;


-(NSString*)woeid;
-(NSString*)title;

@end
