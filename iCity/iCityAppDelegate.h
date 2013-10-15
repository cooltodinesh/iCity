//
//  iCityAppDelegate.h
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "iCityMainViewController.h"
#import "GAI.h"



@interface iCityAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, strong) Facebook	*facebook;

@property (nonatomic , strong) iCityMainViewController *mainView;

@property (strong, nonatomic) NSMutableDictionary *cityToFriendMappingG;

@property (strong, nonatomic) NSMutableArray *cityFriendDictionaryArrayG;
@property(nonatomic, strong) NSDictionary *cityDictionary;

@property (strong, nonatomic) NSDictionary *allCityTaxiNumber;
-(BOOL)isInternetConnected;

@property(nonatomic, retain) id<GAITracker> tracker;

@end
