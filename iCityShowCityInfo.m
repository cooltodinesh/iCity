//
//  iCityShowCityInfo.m
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//


#import "iCityShowCityInfo.h"
#include <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MLTableAlert.h"
#import <QuartzCore/QuartzCore.h>
#import "iCityAppDelegate.h"
#import "iCityWebViewController.h"

#include <SDWebImage/UIImageView+WebCache.h>


@interface iCityShowCityInfo () <UIAlertViewDelegate>
{
    NSArray *phoneArray;
    NSURL *visitURL;
}

@property (strong, nonatomic) NSMutableSet *phoneNumbers;
@property (strong, nonatomic) NSArray *phoneNumberListArray;
@property (strong, nonatomic) MLTableAlert *alert;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) NSString *myNumber;
@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *cabTitle;

@end

@implementation iCityShowCityInfo

@synthesize sectionArray, rowArray, phoneNumbers, alert, phoneNumberListArray, alertView, myNumber, myName, cabTitle;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"show city info view did load");
    
    self.phoneNumbers = [[NSMutableSet alloc] initWithCapacity:10];
    
    
    iCityAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    BOOL connected = [delegate isInternetConnected];
    
    if(!connected)
    {
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Error!!"
                                                          message:@"No Internet connection found"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
//    NSLog(@"numberOfSectionsInTableView");
    
    // Return the number of sections.
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"numberOfRowsInSection");
    
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return [[self.rowArray objectAtIndex:section] count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    NSLog(@"titleForHeaderInSection");
    return [self.sectionArray objectAtIndex:section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
//    NSLog(@"viewForHeaderInSection");
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    headerLabel.frame = CGRectMake(11,-11, 320.0, 44.0);
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.text = [self.sectionArray objectAtIndex:section];
    [headerView addSubview:headerLabel];
    
    //        headerView.layer.borderColor = [UIColor blackColor].CGColor;
    //        headerView.layer.borderWidth = 1;
    
    
    [headerView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]];
    
    
    
    return headerView;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSLog(@"cellForRowAtIndexPath : %@", indexPath);
    
    
    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell =   [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    
    
    if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Facebook Friends Nearby"])
    {
        
        if([[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            cell.textLabel.text = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
//            cell.imageView.image = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"small_pic"];
            
            [cell.imageView setImageWithURL:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"small_pic"] placeholderImage:[UIImage imageNamed:@"dummy.gif"]];
            

        }
        else
        {
            cell.textLabel.text =  [[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.imageView.image = nil;
        }
        
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Taxi"])
    {
//        cell.textLabel.text =  [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleNoFormatting"];
        
        cell.textLabel.text = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cabname"];
        
        cell.imageView.image = [UIImage imageNamed:@"taxi.jpg"];
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Hospitals"])
    {
        self.cabTitle = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleNoFormatting"];
        cell.textLabel.text =  [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleNoFormatting"];
        cell.imageView.image = [UIImage imageNamed:@"hospital.jpg"];
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Hotels"])
    {
        
        self.cabTitle = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleNoFormatting"];
        cell.textLabel.text =  [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleNoFormatting"];
        cell.imageView.image = [UIImage imageNamed:@"hotel.png"];
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Weather"])
    {
        int base=0;
        int increament = 63;
        
        NSDictionary *todayWeather;
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:0];
        
//        NSDictionary *todayWeather = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%u - %u", ([[weekday objectForKey:@"low"] integerValue]-32)*5/9, ([[weekday objectForKey:@"high"] integerValue]-32)*5/9],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"text"]],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"day"]] ,nil] forKeys:[NSArray arrayWithObjects:@"temperature",@"climate",@"day", nil]];
        
//        NSLog(@"today info : %@", todayWeather);
        
        UIView *customCell1 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp1.text = [todayWeather objectForKey:@"temperature"];
        UIImage *weatherImage1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        if(!weatherImage1)
        {
            weatherImage1 = [UIImage imageNamed:@"defaultweather.gif"];
        }
        
        UIImageView *weatherImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView1.image = weatherImage1;
        [customCell1 addSubview:weatherImageView1];
        [customCell1 addSubview:temp1];
        UILabel *day1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day1.text = [todayWeather objectForKey:@"day"];
        customCell1.layer.borderColor = [UIColor grayColor].CGColor;
        customCell1.layer.borderWidth = 1.0f;
        [customCell1 addSubview:day1];
        
//        NSLog(@"no space weather = %@",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        
        
        base+=increament+1;
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:1];
        
        UIView *customCell2 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp2.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        if(!weatherImage2)
        {
            weatherImage2 = [UIImage imageNamed:@"defaultweather.gif"];
        }
        
        UIImageView *weatherImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView2.image = weatherImage2;
        [customCell2 addSubview:weatherImageView2];
        [customCell2 addSubview:temp2];
        UILabel *day2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day2.text = [todayWeather objectForKey:@"day"];
        customCell2.layer.borderColor = [UIColor grayColor].CGColor;
        customCell2.layer.borderWidth = 1.0f;
        [customCell2 addSubview:day2];
        
        base+=increament+1;
        
//        NSLog(@"no space weather = %@",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:2];
        
        UIView *customCell3 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp3.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        if(!weatherImage3)
        {
            weatherImage3 = [UIImage imageNamed:@"defaultweather.gif"];
        }
        
        UIImageView *weatherImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView3.image = weatherImage3;
        [customCell3 addSubview:weatherImageView3];
        [customCell3 addSubview:temp3];
        UILabel *day3 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day3.text = [todayWeather objectForKey:@"day"];
        customCell3.layer.borderColor = [UIColor grayColor].CGColor;
        customCell3.layer.borderWidth = 1.0f;
        [customCell3 addSubview:day3];
        
        base+=increament+1;
        
//        NSLog(@"no space weather = %@",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:3];
        
        UIView *customCell4 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp4 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp4.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        if(!weatherImage4)
        {
            weatherImage4 = [UIImage imageNamed:@"defaultweather.gif"];
        }
        
        UIImageView *weatherImageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView4.image = weatherImage4;
        [customCell4 addSubview:weatherImageView4];
        [customCell4 addSubview:temp4];
        UILabel *day4 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day4.text = [todayWeather objectForKey:@"day"];
        customCell4.layer.borderColor = [UIColor grayColor].CGColor;
        customCell4.layer.borderWidth = 1.0f;
        [customCell4 addSubview:day4];
        
        base+=increament+1;
        
//        NSLog(@"no space weather = %@",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:4];
        
        UIView *customCell5 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp5 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp5.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage5 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        
        if(!weatherImage5)
        {
            weatherImage5 = [UIImage imageNamed:@"defaultweather.gif"];
        }
        
        UIImageView *weatherImageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView5.image = weatherImage5;
        [customCell5 addSubview:weatherImageView5];
        [customCell5 addSubview:temp5];
        UILabel *day5 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day5.text = [todayWeather objectForKey:@"day"];
        customCell5.layer.borderColor = [UIColor grayColor].CGColor;
        customCell5.layer.borderWidth = 1.0f;
        [customCell5 addSubview:day5];
        
//        NSLog(@"no space weather = %@",[(NSString*)[todayWeather objectForKey:@"climate"] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        
        [cell.viewForBaselineLayout addSubview:customCell1 ];
        [cell.viewForBaselineLayout addSubview:customCell2 ];
        [cell.viewForBaselineLayout addSubview:customCell3 ];
        [cell.viewForBaselineLayout addSubview:customCell4 ];
        [cell.viewForBaselineLayout addSubview:customCell5 ];
    }
    else
    {
        cell.textLabel.text =  [[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.imageView.image = nil;
    }
    
    
    //NSLog(@"section : %u index : %u", indexPath.section,indexPath.row);
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSLog(@"heightForRowAtIndexPath");
    
    if(indexPath.section == 0 &&  [[self.rowArray objectAtIndex:indexPath.section] count]>1)
    {
        
        return 110;
    }
    else
        return 45;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSLog(@"didSelectRowAtIndexPath");
    
    
    if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Taxi"])
    {
        
        BOOL urlFound;
        BOOL numberFound;
        NSString *cabname = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cabname"];
        
        self.cabTitle = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cabname"];

        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]]];
        
        
        if( [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"number"] )
        {
            numberFound = YES;
            phoneArray = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"number"];
//            NSLog(@"has number");
//            NSLog(@"number=%@", phoneArray);

        }
        else
        {
            numberFound = NO;
//            NSLog(@"number not found");
        }
        
        
        if( [[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"] isKindOfClass:[NSNull class]])

        {
//            NSLog(@"URL is not present");
            urlFound = NO;
            
        }
        else
        {
            
            urlFound = YES;
            visitURL = [NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]];
//            NSLog(@"URL is present %@",[NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]]);
        }
        
        if ( urlFound && numberFound  )
        {
            
            self.alertView = [[UIAlertView alloc] initWithTitle:cabname
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles: @"Call Taxi", @"Visit website",nil
                              ];
            [self.alertView show];

            
        }
        else if ( urlFound )
        {
            
//            [[UIApplication sharedApplication] openURL:visitURL];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            
            iCityWebViewController *web = [storyBoard instantiateViewControllerWithIdentifier:@"iCityWebViewController"];
            web.url = visitURL;
            
            web.title = self.cabTitle;
            
            [self.navigationController pushViewController:web animated:YES];
            
        }
        else if ( numberFound )
        {
            
            self.alert = [MLTableAlert tableAlertWithTitle:@"Choose the number" cancelButtonTitle:@"Cancel" numberOfRows:^NSInteger (NSInteger section)
                          {
                              return [phoneArray count];
                          }
                                                  andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
                          {
                              static NSString *CellIdentifier = @"CellIdentifier";
                              UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                              if (cell == nil)
                                  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                              
                              cell.textLabel.text = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:indexPath.row] ];
                              
                              return cell;
                          }];
            
            // Setting custom alert height
            self.alert.height = 250;
            
            [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
                
                NSString *tmpNumber = [phoneArray objectAtIndex:selectedIndex.row];
                
//                NSString * strippedNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [number length])];

                NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",@"tel:",[tmpNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpNumber length])] ]];
                
                [[UIApplication sharedApplication]openURL:url];
                
                
            } andCompletionBlock:^{
//                NSLog(@"No number selected");
            }];
            
            // show the alert
            [self.alert show];
            
            
        }
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Hospitals"])
    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]]];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        visitURL = [NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]];
        
        iCityWebViewController *web = [storyBoard instantiateViewControllerWithIdentifier:@"iCityWebViewController"];
        web.url = visitURL;
        
        web.title = self.cabTitle;
        
        [self.navigationController pushViewController:web animated:YES];
        
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Hotels"])
    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]]];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        visitURL = [NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]];
        
        iCityWebViewController *web = [storyBoard instantiateViewControllerWithIdentifier:@"iCityWebViewController"];
        web.url = visitURL;
        
        web.title = self.cabTitle;
        
        [self.navigationController pushViewController:web animated:YES];
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Facebook Friends Nearby"])
    {
        
        [self.phoneNumbers removeAllObjects];
        
//        NSLog(@"selected fb friend");
        
        if([[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
        {
//            NSLog(@"fetching contacts");
            
            NSString *name = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
//            NSLog(@"name from fb = %@",name);
            
            CFErrorRef * error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        
//                        NSLog(@"no permission granted");
                        
                    } else {
                        
                        NSString *contactName;
                        
                        CFArrayRef allPeople =    ABAddressBookCopyArrayOfAllPeople( addressBook );
                        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
                        
                        for ( int i = 0; i < nPeople; i++ )
                        {
                            ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
                            
                            ABMutableMultiValueRef multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);

                            contactName = (__bridge NSString *)(ABRecordCopyCompositeName(ref));
                            
                            if(![name compare:contactName])
                            {    
                                
//                                NSLog(@"fb name is : %@", ABRecordCopyValue(ref, kABPersonSocialProfileServiceFacebook));
                                
//                                NSLog(@"fb name is : %@", ABRecordCopyValue(ref, kABPersonSocialProfileServiceFacebook));
                                
                                self.myName = contactName;
                                
                                for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++)
                                    
                                {
                                    
                                    CFStringRef number = ABMultiValueCopyValueAtIndex(multi, i);
                                    
                                    [self.phoneNumbers addObject:(__bridge NSString*)number];
                                    
                                    NSLog(@"adding %@ for %@",(__bridge NSString*)number , contactName);
                                    
                                    CFRelease(number);
                                    
                                }
                            }
                            
                            CFRelease(multi);
                            
                        }
                        
                        CFRelease(allPeople);
                        
                        if(self.phoneNumbers.count)
                        {
                                                            
                                self.alertView = [[UIAlertView alloc] initWithTitle:@"Choose one"
                                                                            message:[NSString stringWithFormat:@"How would you like to reach %@ ?", self.myName]
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Cancel"
                                                                  otherButtonTitles:@"Call", @"Message",nil
                                                  ];
                                [self.alertView show];

                                
                        }
                        else
                        {
//                            NSLog(@"No numbers found");
                            
                            UIAlertView *noContactAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No phone number found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            
                            [noContactAlert show];
                            
                        }
                        
                        
                    }
                });
            });
            
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertLocalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *pressedButton = [alertLocalView buttonTitleAtIndex:buttonIndex];
    
    if( [pressedButton isEqualToString:@"Call"] )
    {
        
        NSArray *array = [NSArray arrayWithArray:[self.phoneNumbers allObjects]];

        self.alert = [MLTableAlert tableAlertWithTitle:@"Choose the number" cancelButtonTitle:@"Cancel" numberOfRows:^NSInteger (NSInteger section)
                      {
                          return [array count];
                      }
                                              andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
                      {
                          static NSString *CellIdentifier = @"CellIdentifier";
                          UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                          if (cell == nil)
                              cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                          
                          cell.textLabel.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row] ];
                          
                          return cell;
                      }];
        
        // Setting custom alert height
        self.alert.height = 250;
        
        [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            
            NSString *tmpNumber = [array objectAtIndex:selectedIndex.row];
            
            //            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",tmpNumber]];
            
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",@"tel:",[tmpNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpNumber length])]]];
            
            
            [[UIApplication sharedApplication]openURL:url];
            
            
        } andCompletionBlock:^{
//            NSLog(@"No number selected");
        }];
        
        // show the alert
        [self.alert show];
        
        
        
        
    }
    else if ( [pressedButton isEqualToString:@"Message"] )
    {
        
        
        NSArray *array = [NSArray arrayWithArray:[self.phoneNumbers allObjects]];
        
        self.alert = [MLTableAlert tableAlertWithTitle:@"Choose the number" cancelButtonTitle:@"Cancel" numberOfRows:^NSInteger (NSInteger section)
                      {
                          return [array count];
                      }
                                              andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
                      {
                          static NSString *CellIdentifier = @"CellIdentifier";
                          UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                          if (cell == nil)
                              cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                          
                          cell.textLabel.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row] ];
                          
                          return cell;
                      }];
        
        // Setting custom alert height
        self.alert.height = 250;
        
        [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            
            NSString *tmpNumber = [array objectAtIndex:selectedIndex.row];
            
            //            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",tmpNumber]];
            
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",@"sms:",[tmpNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpNumber length])]]];
            
            
            [[UIApplication sharedApplication]openURL:url];
            
            
        } andCompletionBlock:^{
//            NSLog(@"No number selected");
        }];
        
        // show the alert
        [self.alert show];
        
        
    }
    else if ( [pressedButton isEqualToString:@"Call Taxi"] )
    {
        self.alert = [MLTableAlert tableAlertWithTitle:@"Choose the number" cancelButtonTitle:@"Cancel" numberOfRows:^NSInteger (NSInteger section)
                      {
                          return [phoneArray count];
                      }
                                              andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
                      {
                          static NSString *CellIdentifier = @"CellIdentifier";
                          UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                          if (cell == nil)
                              cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                          
                          cell.textLabel.text = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:indexPath.row] ];
                          
                          return cell;
                      }];
        
        // Setting custom alert height
        self.alert.height = 250;
        
        [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            
            NSString *tmpNumber = [phoneArray objectAtIndex:selectedIndex.row];
            
//            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",tmpNumber]];
            
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",@"tel:",[tmpNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpNumber length])]]];
            
            
            [[UIApplication sharedApplication]openURL:url];
            
            
        } andCompletionBlock:^{
//            NSLog(@"No number selected");
        }];
        
        // show the alert
        [self.alert show];
    }
    else if ( [pressedButton isEqualToString:@"Visit website"] )
    {
//        [[UIApplication sharedApplication] openURL:visitURL];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        iCityWebViewController *web = [storyBoard instantiateViewControllerWithIdentifier:@"iCityWebViewController"];
        web.url = visitURL;
        
        web.title = self.cabTitle;
        
        [self.navigationController pushViewController:web animated:YES];

        
    }
    else if ( [pressedButton isEqualToString:@"Cancel"] )
    {
        
        
    }

    
    
}



@end