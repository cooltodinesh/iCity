//
//  iCityMainViewController.h
//  iCity
//
//  Created by Dinesh Salve on 19/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCityTableViewConroller.h"
#import "iCityMapViewController.h"

@interface iCityMainViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) iCityTableViewConroller *cityView;

@property (strong, nonatomic) iCityMapViewController *mapView;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *tableDataSections;
@property (strong,nonatomic) NSString *cityname;
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) UIImageView *barView;

-(void)presentCity;

-(CGFloat)screenHeight;
-(CGFloat)screenWidth;
-(void)willShowCity;

@end
