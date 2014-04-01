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
#import "UserPreference.h"
#import "Preference.h"

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
        if (sum==0){
            [returnArray addObject:[[NSNumber alloc] initWithFloat:0.0]];
        }
        else{
            [returnArray addObject:[[NSNumber alloc] initWithFloat:[cur floatValue]/sum]];
        }
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

#warning Need to test all of these functions
/*
 Functions that have been tested:
    -None
 
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
    switch (chosenValue) {
        case 0:
            //Means that we want all men
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] == 0){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 1:
            //Means that we want majority men, so normalize around 25%
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:(ABS(25  - [preferenceValues[i] intValue]))];
            }
            //Then invert the list using the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            break;
        }
            
        case 2:
            //Means that we want neutral, so normalize around 50%
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:(ABS(50  - [preferenceValues[i] intValue]))];
            }
            //Then invert the list using the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            break;
        }
            
        case 3:
            //Means that we want majority women, so normalize around 75%
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:(ABS(75  - [preferenceValues[i] intValue]))];
            }
            //Then invert the list using the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            break;
        }
            
        case 4:
            //Means that we want all female
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] != 100){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
    }
    return normalize(preferenceValues);
}

NSMutableArray * normalizeFromType(NSMutableArray* preferenceValues, int chosenValue){
    switch (chosenValue) {
        case 0:
            //Means that we want public
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] != 1){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 1:
            //Means that we want private
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] != 2){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 2:
            //Means that we want private, non-profit
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] != 3){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
    }
    return normalize(preferenceValues);
}
NSMutableArray * normalizeFromDegree(NSMutableArray* preferenceValues, int chosenValue){
    switch (chosenValue) {
        case 0:
            //Means that we want no degrees
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] == 0){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 1:
            //Means that we want at least Associate's (any of 11,12,13,14,20,30,40)
        {
            NSArray* degrees = @[@11,@12,@13,@14,@20,@30,@40,@"11",@"12",@"13",@"14",@"20",@"30",@"40"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([degrees containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 2:
            //Means that we want at least Bachelor's (any of 11,12,13,14,20,30)
        {
            NSArray* degrees = @[@11,@12,@13,@14,@20,@30,@"11",@"12",@"13",@"14",@"20",@"30"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([degrees containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 3:
            //Means that we want at least Master's (any of 11,12,13,14,20)
        {
            NSArray* degrees = @[@11,@12,@13,@14,@20,@"11",@"12",@"13",@"14",@"20"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([degrees containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 4:
            //Means that we want at least Doctor's (any of 11,12,13,14)
        {
            NSArray* degrees = @[@11,@12,@13,@14,@"11",@"12",@"13",@"14"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([degrees containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
    }
    return normalize(preferenceValues);
}
NSMutableArray * normalizeFromReligion(NSMutableArray* preferenceValues, int chosenValue){
    switch (chosenValue) {
        case 0:
            //Means that we want no religious affiliation
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] == -2){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 1:
            //Means that we want any catholic affiliation (30,91,92)
        {
            NSArray* religions = @[@30,@91,@92,@"30",@"91",@"92"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([religions containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 2:
            //We want any protestant religion - Anything that is not (-2,30,80,91, or 92)
        {
            NSArray* religions = @[@(-2),@30,@80,@91,@92,@"-2",@"30",@"80",@"91",@"92"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([religions containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
            }
            break;
        }
            
        case 3:
            //Means that we want Jewish affiliation - (80)
        {
            NSArray* religions = @[@80,@"80"];
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([religions containsObject:preferenceValues[i]]){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
                }
                else{
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
    }
    return normalize(preferenceValues);
}

NSMutableArray * normalizeFromCity(NSMutableArray* preferenceValues, int chosenValue){
    //translate acceptedValue choice to what the city code is in the database
    int cityType = 0;
    switch (chosenValue) {
        case 0:
            cityType = 11;
            break;
        case 1:
            cityType = 12;
            break;
        case 2:
            cityType = 13;
            break;
        case 3:
            cityType = 21;
            break;
        case 4:
            cityType = 22;
            break;
        case 5:
            cityType = 23;
            break;
        case 6:
            cityType = 31;
            break;
        case 7:
            cityType = 32;
            break;
        case 8:
            cityType = 33;
            break;
        case 9:
            cityType = 41;
            break;
        case 10:
            cityType = 42;
            break;
        case 11:
            cityType = 43;
            break;
    }
    
    //if it's that code, give them 100%, else you get 0%
    for (int i = 0; i<[preferenceValues count]; i++){
        if ([preferenceValues[i] intValue] == cityType){
            preferenceValues[i] = [[NSNumber alloc] initWithInt:1];
        }
        else{
            preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
        }
    }

    return normalize(preferenceValues);
}




#pragma mark - Generate Rankings


NSMutableDictionary * generateRankings(){
    PreferenceManager *prefMan = [PreferenceManager sharedInstance];
    InstitutionManager *instMan = [InstitutionManager sharedInstance];
    NSMutableArray* normalizedPrefs = [NSMutableArray new];
    NSMutableArray* weightArr = [NSMutableArray new];

    for (UserPreference* userPref in [prefMan getAllUserPrefs])
    {
        NSMutableArray* value = [NSMutableArray new];
        if([[userPref getName] isEqualToString:@"Public or Private"])
        {
            value = normalizeFromType([instMan getValuesForPreference:@"type"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Location"])
        {
            value = normalizeFromDistance([instMan getValuesForPreference:@"location"], [userPref getPrefVal]);
        }
        
        else if([[userPref getName] isEqualToString:@"Size of City"])
        {
            value = normalizeFromCity([instMan getValuesForPreference:@"urbanization"], [userPref getPrefVal]);
        }
        
        else if([[userPref getName] isEqualToString:@"Average SAT Score"])
        {
            value = normalizeFromSAT([instMan getValuesForPreference:@"sat"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Football Team"])
        {
            value = normalizeFromFootball([instMan getValuesForPreference:@"football"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Basketball Team"])
        {
            value = normalizeFromBasketball([instMan getValuesForPreference:@"basketball"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Baseball Team"])
        {
            value = normalizeFromBaseball([instMan getValuesForPreference:@"baseball"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Cross Country Team"])
        {
            value = normalizeFromXC([instMan getValuesForPreference:@"xCountryAndTrack"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Available Daycare"])
        {
            value = normalizeFromDaycare([instMan getValuesForPreference:@"dayCare"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Study Abroad Oppurtunities"])
        {
            value = normalizeFromStudyAbroad([instMan getValuesForPreference:@"studyAbroad"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Number of Students"])
        {
            value = normalizeFromSize([instMan getValuesForPreference:@"size"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"College Selectivity"])
        {
            value = normalizeFromSelectivity([instMan getValuesForPreference:@"selectivity"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Student Faculty Ratio"])
        {
            value = normalizeFromStudentRatio([instMan getValuesForPreference:@"studentFacultyRatio"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Gender Ratio"])
        {
            value = normalizeFromFemaleRatio([instMan getValuesForPreference:@"femaleRatio"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Highest Available Degree"])
        {
            value = normalizeFromDegree([instMan getValuesForPreference:@"type"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Tuition"])
        {
            value = normalizeFromCost([instMan getValuesForPreference:@"cost"], [userPref getPrefVal]);
        }
        else if([[userPref getName] isEqualToString:@"Religious Affiliation"])
        {
            value = normalizeFromReligion([instMan getValuesForPreference:@"religiousAffiliation"], [userPref getPrefVal]);
        }
        else{
        }
        NSLog(@"%@ - %@",[userPref getName],value);
        [weightArr addObject:[NSNumber numberWithInt:[userPref getWeight]]];
        [normalizedPrefs addObject: value];
    }
    NSMutableDictionary* weightDict = calculatePreferences(normalizedPrefs, weightArr);
    NSMutableArray* instNames = [instMan getUserInstitutionNames];
    NSMutableDictionary* rankedInstitutions = [NSMutableDictionary new];
    for(int i=0; i<[instNames count]; i++)
    {
        NSString* index = [NSString stringWithFormat:@"%i", i];
        [rankedInstitutions setObject:[weightDict objectForKey:index] forKey:[instNames objectAtIndex:i]];
    }
    
    return rankedInstitutions;
}


NSMutableDictionary * calculatePreferences(NSMutableArray * incomingInstitutions, NSMutableArray* weights){
    
    NSMutableDictionary* cardinalUtilities = [NSMutableDictionary new];
    for(int i=0; i<[incomingInstitutions count]; i++)
    {
        NSMutableArray* tempArr = [incomingInstitutions objectAtIndex:i];
        for(int j=0;j<[tempArr count];j++)
        {
            float weightedValue = [[tempArr objectAtIndex:j] floatValue] * [[weights objectAtIndex:i] floatValue];
            NSString* nsJ = [[NSString alloc] initWithFormat:@"%i", j];
            if([cardinalUtilities objectForKey:nsJ])
            {
                float wtVal = [[cardinalUtilities valueForKey:nsJ] floatValue] + weightedValue;
                [cardinalUtilities setObject:[NSNumber numberWithFloat:wtVal] forKey:nsJ];
            }
            else
            {
                [cardinalUtilities setObject:[NSNumber numberWithFloat:weightedValue] forKey:nsJ];
                
            }
        }
    }
    return cardinalUtilities;
}

