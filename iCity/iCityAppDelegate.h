//
//  iCityAppDelegate.h
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface iCityAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) Facebook	*facebook;

@end
