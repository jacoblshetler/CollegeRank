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

CLLocation *didCalculateDistance(NSString* zipCode) {
    CLLocation __block *placemark = [CLLocation new];
    
    [[CLGeocoder new] geocodeAddressString:zipCode completionHandler:
     ^(NSArray *placemarks, NSError *error){
         CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
         placemark = newPlacemark.location;
         NSLog(@"HERE");
     }];

    
    NSLog(@"%@",placemark);
    return placemark;
}








double geoDistance(NSString * zip1, NSString * zip2){
    CLLocation *location1 = didCalculateDistance(zip1);
    CLLocation *location2 = didCalculateDistance(zip2);
    
    CLLocationDistance meters = [location1 distanceFromLocation:location2];
    return (double)meters;
}




NSMutableDictionary * generateRankings(NSMutableArray * usedInstitutions){
    
    return [[NSMutableDictionary alloc] init];
}


NSMutableArray * calculatePreferences(NSMutableArray * incomingInstitutions){
    
    return [[NSMutableArray alloc] init];
}

