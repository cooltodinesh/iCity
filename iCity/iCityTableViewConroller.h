//
//  iCityTableViewConroller.h
//  iCity
//
//  Created by Dinesh Salve on 13/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <UIKit/UIKit.h>


@class iCityMainViewController;

@interface iCityTableViewConroller : UITableViewController 

@property(nonatomic, strong) NSDictionary *cityDictionary;
@property(nonatomic, strong) NSArray *cityList;
@property(nonatomic, strong) NSArray *citySearchList;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *tableDataSections;
@property (strong, nonatomic) NSDictionary *stateDictionary;

@property (strong, nonatomic) iCityMainViewController *mainView;


@end
