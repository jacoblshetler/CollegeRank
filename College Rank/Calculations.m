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
    float sum = [[prefValues valueForKeyPath:@"@sum.self"] floatValue];
    
    NSMutableArray* returnArray = [[NSMutableArray alloc]init];
    for (NSDecimalNumber * cur in prefValues){
        //divide each item in the array by the sum
        [returnArray addObject:[[NSNumber alloc] initWithFloat:[cur floatValue]/sum]];
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

NSMutableArray * normalizeFromSize(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromDistance(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromSAT(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromDistance(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromSelectivity(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromDistance(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromStudentRatio(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromDistance(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromCost(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromDistance(preferenceValues, chosenValue);
}

//BOOLs are all or nothing when normalized.
NSMutableArray * normalizeFromBool(NSMutableArray* preferenceValues, int chosenValue){
    switch (chosenValue) {
        case 0:
            //Means that we want 0's, so invert each one.
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] == 1){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
            }
            break;
            
        case 1:
            //Means that we don't need to change anything
            break;
    }
    return normalize(preferenceValues);
}
NSMutableArray * normalizeFromFootball(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromBool(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromBaseball(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromBool(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromBasketball(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromBool(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromXC(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromBool(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromDaycare(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromBool(preferenceValues, chosenValue);
}
NSMutableArray * normalizeFromStudyAbroad(NSMutableArray* preferenceValues, int chosenValue){
    return normalizeFromBool(preferenceValues, chosenValue);
}

//Various methods that don't fit together
NSMutableArray * normalizeFromFemaleRatio(NSMutableArray* preferenceValues, int chosenValue){
    return [[NSMutableArray alloc] init];
}
NSMutableArray * normalizeFromType(NSMutableArray* preferenceValues, int chosenValue){
    return [[NSMutableArray alloc] init];
}
NSMutableArray * normalizeFromDegree(NSMutableArray* preferenceValues, int chosenValue){
    return [[NSMutableArray alloc] init];
}
NSMutableArray * normalizeFromReligion(NSMutableArray* preferenceValues, int chosenValue){
    return [[NSMutableArray alloc] init];
}
NSMutableArray * normalizeFromCity(NSMutableArray* preferenceValues, int chosenValue){
    return [[NSMutableArray alloc] init];
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

