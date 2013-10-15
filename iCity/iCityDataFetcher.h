//
//  iCityDataFetcher.h
//  iCity
//
//  Created by Dinesh Salve on 19/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iCityTableViewConroller;
@class iCityMapViewController;

@interface iCityDataFetcher : NSObject

@property(nonatomic, strong) NSDictionary *cityDictionary;
@property(nonatomic, strong) NSArray *cityList;
@property (nonatomic, strong) NSArray *allCityInfo;

-(void)getCityList:(iCityTableViewConroller*)tableView;
-(void)getAllAnnotations:(iCityMapViewController*)mapView;

@end
