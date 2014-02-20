//
//  Calculations.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "Calculations.h"

@implementation Calculations


+ (NSMutableArray *) normalize: (NSMutableArray *) prefValues{
    //create the sum values
    NSDecimalNumber* sum = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    for (NSDecimalNumber * cur in prefValues){
        //loop thru and add all values to the sum
        sum = [sum decimalNumberByAdding:cur];
    }
    
    NSMutableArray* returnArray = [[NSMutableArray alloc]init];
    for (NSDecimalNumber * cur in prefValues){
        //divide each item in the array by the sum
        [returnArray addObject:[cur decimalNumberByDividingBy:sum]];
    }
    return returnArray;
}


+ (float) geoDistance: (NSString *)zip1 : (NSString *) zip2{
    
    return 0.0f;
}


+ (NSMutableDictionary *) generateRankings: (NSMutableArray *) usedInstitutions{
    
    return [[NSMutableDictionary alloc] init];
}


- (NSMutableArray *) calculatePreferences: (NSMutableArray *) incomingInstitutions{
    
    return [[NSMutableArray alloc] init];
}

@end
