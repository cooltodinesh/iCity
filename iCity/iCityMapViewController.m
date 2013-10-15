//
//  iCityMapViewController.m
//  iCity
//
//  Created by Dinesh Salve on 19/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityMapViewController.h"
#import "iCityAnnotation.h"
#import "iCityAppDelegate.h"
#import "iCityProcessor.h"
#import "iCityMainViewController.h"

#include <math.h>
#define PI 3.1415

@interface iCityMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSArray *annotations;

@end

@implementation iCityMapViewController

@synthesize allCityInfo, annotations, mapView, mainView;


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    iCityAnnotation *annotation = view.annotation;
    
    NSLog(@"woeid tapped is : %@", annotation.woeid);
    
    iCityAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
//    if( [appDelegate isInternetConnected] )
//    {
    
        appDelegate.mainView.cityname = [annotation title];
        
        
        //    appDelegate.mainView.activity.hidden = NO;
        
        [self.mainView willShowCity];
        
    
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            iCityProcessor *processor = [[iCityProcessor alloc] init];
            processor.citywoeid = annotation.woeid;
            processor.caller = self;
            
            [processor processCity:[annotation title]];
            
//            NSLog(@"calling processor");
        });
//    }
//    else
//    {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Error!!"
//                                                          message:@"No Internet connection found"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//            [message show];
//    }
    
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
    annotationView.canShowCallout = YES;
    annotationView.annotation = annotation;
    return annotationView;
    
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
	// Do any additional setup after loading the view.
    
    
    //"latitude":"21.15145","longitude":"78.952968"
    
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D centerLocation;
    centerLocation.latitude = 21.15145; //nagpur location
    centerLocation.longitude = 78.952968;
    
    MKCoordinateRegion region;
    region = self.mapView.region;
    region.center = centerLocation;
    region.span.longitudeDelta = 30.0;

    self.mapView.region = region;
    
    
//    UILongPressGestureRecognizer *tap= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap:)];
    
    UILongPressGestureRecognizer *tap= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap:)];
    
    [self.mapView addGestureRecognizer:tap];
    
//    NSLog(@"span : %f %f",region.span.latitudeDelta, region.span.longitudeDelta );
    
}

-(void)tapOnMap:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    if(self.mapView.annotations.count)
    {
        [self.mapView removeAnnotations:self.annotations];
    }
    
    double min = 99999999999.0;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    NSDictionary *nearestCity;
    
    for(NSDictionary *city in self.allCityInfo)
    {
        
        NSData *locationDetails = [city objectForKey:@"location"];
        
        CLLocationCoordinate2D selectedCity;
        [locationDetails getBytes:&selectedCity];
        
        double tmpDistance = [self getDistancebetweenpointone:selectedCity andpointTwo:touchMapCoordinate];
        
        if(tmpDistance < min)
        {
            min = tmpDistance;
            nearestCity = city;
        }
        
    }
    
    iCityAnnotation *annotation = [iCityAnnotation annotationForUser:[[NSDictionary alloc] initWithObjectsAndKeys:[nearestCity objectForKey:@"county"],@"county",[nearestCity objectForKey:@"woeid"],@"woeid",[nearestCity objectForKey:@"location"],@"location", nil]];

    
    [self.mapView addAnnotation:annotation];
    
    
    
    MKCoordinateRegion region;
    region = self.mapView.region;
    region.center = touchMapCoordinate;
    region.span = self.mapView.region.span;
    
    self.mapView.region = region;
    
    

}

-(double)getDistancebetweenpointone:(CLLocationCoordinate2D)point1 andpointTwo:(CLLocationCoordinate2D)point2
{
    double R = 6371; // km
    double dLat = (point2.latitude - point1.latitude)*PI/180;          //(lat2-lat1).toRad();
    double dLon = (point2.longitude-point1.longitude)*PI/180;
    double lat1 = point1.latitude;
    double lat2 = point2.latitude;
    
    double a = sin(dLat/2) * sin(dLat/2) +  sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double d = R * c;
    
//    NSLog(@"distance : %f", d);
    
    return d;
}

//-(void)processAnnotations
//{
//    
//    NSLog(@"all city count : %u", self.allCityInfo.count);
//    
//    NSMutableArray *lannotations = [[NSMutableArray alloc] initWithCapacity:10];
//    
//    for(NSDictionary *city in self.allCityInfo)
//    {
//        NSLog(@"city : %@",city);
//        
//        NSDictionary *pin = [[NSDictionary alloc] initWithObjectsAndKeys:[city objectForKey:@"county"],@"county",[city objectForKey:@"woeid"],@"woeid",[city objectForKey:@"location"],@"location", nil];
//        
//        [lannotations addObject:[iCityAnnotation annotationForUser:pin]];
//        
//    }
//    
//    self.annotations = lannotations;
//    
//    [self updateMapView];
//    
//}

//-(void)updateMapView
//{
//    if(self.annotations.count)
//    {
//        if(self.mapView.annotations.count)
//        {
//            [self.mapView  removeAnnotations:self.mapView.annotations];
//        }
//        
//        [self.mapView addAnnotations:self.annotations];
//        
////        [self.mapView setRegion:self.mapView.region animated:YES];
//        
//        [self.mapView reloadInputViews];
//        
//        NSLog(@"%u annotations added to MKMap",self.mapView.annotations.count);
//        
//    }
//
//}

@end
