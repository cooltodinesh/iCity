//
//  iCityIntroductionViewController.h
//  Indian Cities
//
//  Created by Dinesh Salve on 11/08/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iCityMainViewController.h"

@interface iCityIntroductionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label1;

@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (strong, nonatomic) iCityMainViewController *mainView;

@end
