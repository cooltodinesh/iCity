//
//  iCityProcessor.h
//  iCity
//
//  Created by Dinesh Salve on 23/07/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iCityProcessor : NSObject

@property (strong, nonatomic) id caller;
@property (strong, nonatomic) NSString *citywoeid;

-(void)processCity:(NSString *)city;

@end
