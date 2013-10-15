//
//  iCityMapViewController.h
//  iCity
//
//  Created by Dinesh Salve on 19/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MapKit/MapKit.h>


@class iCityMainViewController;

@interface iCityMapViewController : UIViewController


@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *allCityInfo;

@property (strong, nonatomic) iCityMainViewController *mainView;

-(void)processAnnotations;

@end
