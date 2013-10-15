//
//  iCityMainViewController.m
//  iCity
//
//  Created by Dinesh Salve on 19/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityMainViewController.h"
#include <QuartzCore/QuartzCore.h>
#import "iCityDataFetcher.h"
#import "iCityShowCityInfo.h"
#import "iCityIntroductionViewController.h"

@interface iCityMainViewController () 


@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) iCityDataFetcher *dataFetcher;

@property (strong, nonatomic) iCityShowCityInfo *cityInfo;

@property (strong, nonatomic) iCityIntroductionViewController *intro;

@end

@implementation iCityMainViewController

@synthesize cityView, mapView, barView, dataFetcher, navController, tableDataSections, tableData, cityname, activity, cityInfo, intro;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    

    
    for (UIView *view in self.view.subviews)
    {
        
        if(CGRectContainsPoint(view.frame, touchLocation) && [view isKindOfClass:[UIView class]] && ![view isKindOfClass:[UIImageView class]])
        {
//            NSLog(@"touched view %@", [view class]);
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            
            
            self.barView.frame = CGRectMake(0, 100, [self screenWidth ], 12);
            
            self.cityView.view.frame = CGRectMake(0, 0, [self screenWidth ], self.barView.frame.origin.y - 1 );
            
            self.mapView.view.frame = CGRectMake(0, self.barView.frame.origin.y+12 , [self screenWidth ], [self screenHeight ] - self.barView.frame.origin.y+12);
            
            [UIView commitAnimations];
            
        }
    }
}

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    // displaying introduciton view
    
    
    self.intro = [storyBoard instantiateViewControllerWithIdentifier:@"iCityIntroductionViewController"];
    
    
    
    
    self.intro.view.alpha = 0.6;
    
    self.intro.view.frame = CGRectMake(0, 0, [self screenWidth], [self screenHeight]);
    
    self.intro.mainView = self;
    
//    self.intro.label1.frame = CGRectMake([self screenHeight]/2 - 30, 10, self.intro.label1.frame.size.width, self.intro.label1.frame.size.height);
    

    
//    self.navController = [[UINavigationController alloc] initWithRootViewController:self.intro];
//    
//    [self presentViewController:navController animated:YES completion:nil];
    
    
//    NSLog(@"in main view did load");
    
    self.view.userInteractionEnabled = YES;
    
    dataFetcher = [[iCityDataFetcher alloc] init];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake([self screenWidth]/2 -25 , [self screenHeight]/2 - 25, 50, 50)];
    
    self.activity.hidden = YES;
    self.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
//    [self.activity startAnimating];
    
    
    self.barView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2.png"]];
    
    self.barView.frame = CGRectMake(0, [self screenHeight ]/2 -5, [self screenWidth ], 12);
    
    
    
    self.cityView = [storyBoard instantiateViewControllerWithIdentifier:@"iCityTableViewConroller"];
    
    self.cityView.view.frame = CGRectMake(0, 0, [self screenWidth ], self.barView.frame.origin.y - 1 );
    
    self.cityView.mainView = self;

    
    
    [dataFetcher getCityList:self.cityView];
    
    self.mapView = [storyBoard instantiateViewControllerWithIdentifier:@"iCityMapViewController"];
    
    self.mapView.view.frame = CGRectMake(0, self.barView.frame.origin.y+12 , [self screenWidth ], [self screenHeight ] - self.barView.frame.origin.y+12);
    

    self.mapView.mainView = self;
    
    [dataFetcher getAllAnnotations:self.mapView];
    
//    [self.mapView processAnnotations];
    
    
    
    self.barView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveBar:)];
    
    [self.barView addGestureRecognizer:panGesture];


    
    [self.view addSubview:self.cityView.view];
    [self.view addSubview:self.mapView.view];
    [self.view addSubview:self.barView];
    [self.view addSubview:self.activity];
    
    [self.view addSubview:self.intro.view];

}

- (void)moveBar:(UIPanGestureRecognizer*)gestureRecognizer {
    
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {

        if([piece center].y > 100 && [piece center].y < ([self screenHeight] - 100))
        {
        
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            
            [piece setCenter:CGPointMake([piece center].x , [piece center].y + translation.y)];
            
            self.mapView.view.frame = CGRectMake(0, self.barView.frame.origin.y+12 , [self screenWidth ], [self screenHeight ] - self.barView.frame.origin.y+12);
            
            self.cityView.view.frame = CGRectMake(0, 0, [self screenWidth ], self.barView.frame.origin.y - 1 );
            
            
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        }
    }
    
    
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

-(void)presentCity
{
    
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    
//    self.view.alpha = 1.0;
    self.cityView.view.alpha = 1.0;
    self.mapView.view.alpha = 1.0;
    self.view.userInteractionEnabled = YES;
    self.cityView.searchDisplayController.searchBar.userInteractionEnabled = YES;
    
    cityInfo = [[iCityShowCityInfo alloc] init];
    
    cityInfo.rowArray = [NSArray arrayWithArray:self.tableData];
    cityInfo.sectionArray = [NSArray arrayWithArray:self.tableDataSections];
    cityInfo.title = self.cityname;
    
    cityInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelthis)];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:cityInfo];
    
    self.navController.toolbarHidden = NO;
    self.navController.hidesBottomBarWhenPushed = YES;
    
    
    [self presentViewController:navController animated:YES completion:nil];
    
}


-(void)cancelthis
{
    NSLog(@"cancel in main view");
    [self.navController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"city list has %u elements",self.cityView.cityList.count);
    
}

-(void)willShowCity
{
    NSLog(@"will show city");
    
    self.activity.hidden =NO;
    [self.activity startAnimating];
//    self.view.alpha = 0.5;
    self.cityView.view.alpha = 0.5;
    self.mapView.view.alpha = 0.5;
    self.view.userInteractionEnabled = NO;
}


-(void)viewWillAppear:(BOOL)animated
{
    
        
//    self.searchBar.delegate = self;
}


@end
