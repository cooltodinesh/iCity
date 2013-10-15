//
//  iCityAppDelegate.m
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityAppDelegate.h"
#define APP_ID @"310977542370966"

#define GOOGLE_TRACKING_ID @"UA-41155029-3"

@implementation iCityAppDelegate

@synthesize facebook, window, navigationController, mainView, cityFriendDictionaryArrayG, cityToFriendMappingG, cityDictionary, allCityTaxiNumber;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_TRACKING_ID];
    
    
    
    facebook = [[Facebook alloc] initWithAppId:APP_ID andDelegate:nil];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    self.mainView = [storyBoard instantiateViewControllerWithIdentifier:@"iCityMainViewController"];
    
    self.window.rootViewController = self.mainView;

    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [facebook handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)isInternetConnected
{
    NSLog(@"Waiting for internet connection");
    
    
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    
    if([response statusCode]==200)
    {
        NSLog(@"internet found");
        return YES;
    }
    else
    {
        NSLog(@"internet not found");
        return NO;
    }
    
}


@end
