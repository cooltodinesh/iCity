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

@interface iCityShowCityInfo ()

@property (strong, nonatomic) NSMutableSet *phoneNumbers;
@property (strong, nonatomic) NSArray *phoneNumberListArray;
@property (strong, nonatomic) MLTableAlert *alert;

@end

@implementation iCityShowCityInfo



@synthesize sectionArray, rowArray, phoneNumbers, alert, phoneNumberListArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.phoneNumbers = [[NSMutableSet alloc] initWithCapacity:10];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
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
    return [self.sectionArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Facebook friend nearby"])
    {
        
        if([[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            cell.textLabel.text = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.imageView.image = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"small_pic"];
        }
        else
        {
            cell.textLabel.text =  [[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.imageView.image = nil;
        }
        
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Car Rentals available"])
    {
        cell.textLabel.text =  [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"titleNoFormatting"];
        cell.imageView.image = nil;
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"weather information"])
    {
        int base=0;
        int increament = 63;
        
        NSDictionary *todayWeather;
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:0];
        
//        NSDictionary *todayWeather = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%u - %u", ([[weekday objectForKey:@"low"] integerValue]-32)*5/9, ([[weekday objectForKey:@"high"] integerValue]-32)*5/9],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"text"]],[NSString stringWithFormat:@"%@", [weekday objectForKey:@"day"]] ,nil] forKeys:[NSArray arrayWithObjects:@"temperature",@"climate",@"day", nil]];
        
        NSLog(@"today info : %@", todayWeather);
        
        UIView *customCell1 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp1.text = [todayWeather objectForKey:@"temperature"];
        UIImage *weatherImage1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[todayWeather objectForKey:@"climate"]]];
        UIImageView *weatherImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView1.image = weatherImage1;
        [customCell1 addSubview:weatherImageView1];
        [customCell1 addSubview:temp1];
        UILabel *day1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day1.text = [todayWeather objectForKey:@"day"];
        customCell1.layer.borderColor = [UIColor grayColor].CGColor;
        customCell1.layer.borderWidth = 1.0f;
        [customCell1 addSubview:day1];
        
        
        base+=increament+1;
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:1];
        
        UIView *customCell2 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp2.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[todayWeather objectForKey:@"climate"]]];
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
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:2];
        
        UIView *customCell3 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp3.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[todayWeather objectForKey:@"climate"]]];
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
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:3];
        
        UIView *customCell4 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp4 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp4.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[todayWeather objectForKey:@"climate"]]];
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
        
        todayWeather = [[rowArray objectAtIndex:indexPath.section] objectAtIndex:4];
        
        UIView *customCell5 = [[UIView alloc] initWithFrame:CGRectMake(base, -2, base, 112)];
        UILabel *temp5 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 53, 30)];
        temp5.text = [todayWeather objectForKey:@"temperature"];;
        UIImage *weatherImage5 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[todayWeather objectForKey:@"climate"]]];
        UIImageView *weatherImageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 63, 60)];
        weatherImageView5.image = weatherImage5;
        [customCell5 addSubview:weatherImageView5];
        [customCell5 addSubview:temp5];
        UILabel *day5 = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 58, 30)];
        day5.text = [todayWeather objectForKey:@"day"];
        customCell5.layer.borderColor = [UIColor grayColor].CGColor;
        customCell5.layer.borderWidth = 1.0f;
        [customCell5 addSubview:day5];
        
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
    if(indexPath.section == 0 )
    {
        return 110;
    }
    else
        return 45;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Car Rentals available"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"url"]]];
        
    }
    else if(![(NSString*)[self.sectionArray objectAtIndex:indexPath.section] compare:@"Facebook friend nearby"])
    {
        
        [self.phoneNumbers removeAllObjects];
        
        NSLog(@"selected fb friend");
        
        if([[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"fetching contacts");
            
            NSString *name = [[[rowArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
            NSLog(@"name from fb = %@",name);
            
            CFErrorRef * error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        
                        NSLog(@"no permission granted");
                        
                    } else {
                        
                        
                        
                        CFArrayRef allPeople =    ABAddressBookCopyArrayOfAllPeople( addressBook );
                        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
                        
                        for ( int i = 0; i < nPeople; i++ )
                        {
                            ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
                            
                            ABMutableMultiValueRef multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
                            
                            
                            NSString *contactName = (__bridge NSString *)(ABRecordCopyCompositeName(ref));
                            
                            if(![name compare:contactName])
                            {
                                
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
                            self.phoneNumberListArray = [self.phoneNumbers allObjects];
                            
                            // create the alert
                            self.alert = [MLTableAlert tableAlertWithTitle:@"Choose the number" cancelButtonTitle:@"Cancel" numberOfRows:^NSInteger (NSInteger section)
                                          {
                                              return [self.phoneNumberListArray count];
                                          }
                                                                  andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
                                          {
                                              static NSString *CellIdentifier = @"CellIdentifier";
                                              UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                                              if (cell == nil)
                                                  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                              
                                              cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.phoneNumberListArray objectAtIndex:indexPath.row] ];
                                              
                                              return cell;
                                          }];
                            
                            // Setting custom alert height
                            self.alert.height = 250;
                            
                            [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
                                
                                NSString *tmpNumber = [self.phoneNumberListArray objectAtIndex:selectedIndex.row];
                                
                                NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"tel:", tmpNumber]];
                                
                                [[UIApplication sharedApplication]openURL:url];
                                
                                
                            } andCompletionBlock:^{
                                NSLog(@"No number selected");
                            }];
                            
                            // show the alert
                            [self.alert show];
                            
                            
                        }
                        else
                        {
                            NSLog(@"No numbers found");
                            
                            UIAlertView *noContactAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No phone number found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            
                            [noContactAlert show];
                            
                        }
                        
                        
                    }
                });
            });
            
            
            
            
            
        }
        
        
    }
    
    
}



@end