//
//  Calculations.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "Calculations.h"
#import <CoreLocation/CoreLocation.h>


NSMutableArray * normalize(NSMutableArray * prefValues){
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

#pragma mark - Distance Calculations

CLLocation *didCalculateDistance(NSString* zipCode) {
    CLLocation __block *placemark = [CLLocation new];
    
    [[CLGeocoder new] geocodeAddressString:zipCode completionHandler:
     ^(NSArray *placemarks, NSError *error){
         CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
         placemark = newPlacemark.location;
     }];

    while(!placemark.coordinate.latitude){
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    NSLog(@"%@",placemark);
    return placemark;
}

double geoDistance(NSString * zip1, NSString * zip2){
    CLLocation *location1 = didCalculateDistance(zip1);
    CLLocation *location2 = didCalculateDistance(zip2);
    
    CLLocationDistance meters = [location1 distanceFromLocation:location2];
    return (double)(meters*0.000621371); //converting meters to miles
}

#pragma mark - Preference Calculations
/*
These functions will generate a normalized list of cardinal utilities
based on the type of preference and the acceptedValue that the user
has selected. If an acceptedValue is not present or the rankings are otherwise
unable to be calculated, the function will return all 0's.

None of these functions are declared in the header. This is to ensure that they are
not called from anywhere else in the program.
*/

NSMutableArray * normalizeFromDistance(NSMutableArray* preferences, NSString* acceptedValue){
    //Maximum distance
    
    return [[NSMutableArray alloc] init];
}



#pragma mark - Generate Rankings


NSMutableDictionary * generateRankings(NSMutableArray * usedInstitutions){
    
    return [[NSMutableDictionary alloc] init];
}


NSMutableArray * calculatePreferences(NSMutableArray * incomingInstitutions){
    
    return [[NSMutableArray alloc] init];
}

