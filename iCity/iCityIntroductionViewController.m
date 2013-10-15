//
//  iCityIntroductionViewController.m
//  Indian Cities
//
//  Created by Dinesh Salve on 11/08/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityIntroductionViewController.h"

@interface iCityIntroductionViewController ()

@end

@implementation iCityIntroductionViewController

@synthesize mainView;

-(CGRect)screenRect
{
    return [[UIScreen mainScreen] bounds];
}

-(CGFloat)screenWidth
{
    return [self screenRect].size.width;
    
}

-(CGFloat)screenHeight
{
    return [self screenRect].size.height;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.label1.frame = CGRectMake(0,0, self.label1.frame.size.width, self.label1.frame.size.height);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
    
//    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
    
    
    [self.view addGestureRecognizer:tap];
    [self.view addGestureRecognizer:swipe];
    [self.view addGestureRecognizer:pan];
    [self.view addGestureRecognizer:pinch];
    
	// Do any additional setup after loading the view.
}

-(void) removeView:(UIGestureRecognizer*)tap
{
    [self bringToCenter];
    [self.view removeFromSuperview];
}


-(void)bringToCenter
{
    
    self.mainView.barView.frame = CGRectMake(0, [self screenHeight ]/2 -5, [self screenWidth ], 12);
    
    self.mainView.cityView.view.frame = CGRectMake(0, 0, [self screenWidth ], self.mainView.barView.frame.origin.y - 1 );
    
    self.mainView.mapView.view.frame = CGRectMake(0, self.mainView.barView.frame.origin.y+12 , [self screenWidth ], [self screenHeight ] - self.mainView.barView.frame.origin.y+12);
    
}

@end
