//
//  Calculations.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "Calculations.h"
#import <CoreLocation/CoreLocation.h>
#import "InstitutionManager.h"
#import "PreferenceManager.h"

float median(NSMutableArray* list) {
    if (list.count == 1) return [list[0] floatValue];
    
    float result = 0;
    NSUInteger middle;
    
    NSArray * sorted = [list sortedArrayUsingSelector:@selector(compare:)];
    if (list.count % 2 != 0) {  //odd number of members
        middle = (sorted.count / 2);
        result = [[sorted objectAtIndex:middle] floatValue];
    }
    else {
        middle = (sorted.count / 2) - 1;
        result = [[@[[sorted objectAtIndex:middle], [sorted objectAtIndex:middle + 1]] valueForKeyPath:@"@avg.self"] floatValue];
    }
    return result;
}

NSMutableArray * normalize(NSMutableArray * prefValues){
    //create the sum values
    NSLog(@"%@",prefValues);
    float sum = [[prefValues valueForKeyPath:@"@sum.self"] floatValue];
    
    NSMutableArray* returnArray = [[NSMutableArray alloc]init];
    for (NSDecimalNumber * cur in prefValues){
        //divide each item in the array by the sum
        [returnArray addObject:[[NSNumber alloc] initWithFloat:[cur floatValue]/sum]];
    }
    NSLog(@"%@",returnArray);
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

NSMutableArray * normalizeFromDistance(NSMutableArray* preferenceValues, int chosenValue){
    //3 options to choose from. General ideas are: Close, Middle, Far.
    switch (chosenValue){
        case 0:
        {
            //Subtract each value from the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            
            break;
        }
        case 1:
        {
            //find the middle value and subtract all other values from it, using absolute values.
            NSNumber *medianNum = [[NSNumber alloc] initWithFloat:median(preferenceValues)];
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:(ABS([medianNum intValue]  - [preferenceValues[i] intValue]))];
            }
            //Then invert the list using the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            break;
        }
        case 2:
        {
            //Don't need to do anything since it is already in order
            break;
        }
    }
    return normalize(preferenceValues);
}



#pragma mark - Generate Rankings


NSMutableDictionary * generateRankings(NSMutableArray * usedInstitutions){
    PreferenceManager *prefMan = [PreferenceManager sharedInstance];
    InstitutionManager *instMan = [InstitutionManager sharedInstance];

    return [[NSMutableDictionary alloc] init];
}


NSMutableArray * calculatePreferences(NSMutableArray * incomingInstitutions){

    return [[NSMutableArray alloc] init];
}

