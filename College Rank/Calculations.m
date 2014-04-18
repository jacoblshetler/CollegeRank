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
#import "Institution.h"

#pragma mark - Pure Math Functions

//finds the median of any list
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

NSMutableArray * orderDictKeysDescending(NSDictionary* inDict){
    NSMutableArray* keys = [[NSMutableArray alloc] initWithArray:[inDict allKeys]];
    NSMutableArray* vals = [[NSMutableArray alloc] initWithArray:[inDict allValues]];
    
    //sort the values
    NSArray *sorted = [vals sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 floatValue] < [obj2 floatValue]) return NSOrderedDescending;
        else return NSOrderedAscending;
    }];
    
    //look thru each key and see if its value is the current value, if it is, then add to list and remove
    NSMutableArray* sortedKeys = [[NSMutableArray alloc] init];
    for (int i = 0; i<[vals count]; i++) {
        float currentValue = [[sorted objectAtIndex:i] floatValue];
        
        NSString* stringDelete;
        for (NSString* key in keys) {
            if ([[inDict valueForKey:key] floatValue] == currentValue) {
                stringDelete = key;
            }
        }
        
        [sortedKeys addObject:stringDelete];
        [keys removeObject:stringDelete];
    }
    
    return sortedKeys;
}

//takes dictionary and array and generates what the rank of the index should be based on
//what's before and after it
//the key of the return dictionary will be the index
//the value will be the string of what the ordinal rank of the college is in the cell
NSMutableDictionary * createOrdinalDictionary(NSMutableDictionary* inDict,NSArray* inArray){
    NSMutableDictionary* returnDict = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[inArray count]; i++) {
        //get the current institution and its value
        NSString* curInst = inArray[i];
        NSString* curValue = [NSString stringWithFormat:@"%@",[inDict objectForKey:curInst]];
        
        //get the other value to check
        //if the first index, check if the one after it has the same value
        //if not the first index, check if the one before it has the same value
        NSString* otherValue = [[NSString alloc] init];
        if (i==0) {
            NSString* otherInst = inArray[i+1];
            otherValue = [NSString stringWithFormat:@"%@",[inDict objectForKey:otherInst]];
        }
        else{
            NSString* otherInst = inArray[i-1];
            otherValue = [NSString stringWithFormat:@"%@",[inDict objectForKey:otherInst]];
        }
        
        //check it and set the value in the dictionary
        NSString* ordinalRank = [[NSString alloc]init];
        if ([curValue isEqualToString:otherValue]) {
            if (i==0) {
                ordinalRank = @"1. ";
            }
            else{
                ordinalRank = [returnDict objectForKey:[NSString stringWithFormat:@"%i",i-1]];
                [returnDict setValue:ordinalRank forKey:[NSString stringWithFormat:@"%i",i-1]];
            }
        }
        else{
            ordinalRank = [NSString stringWithFormat:@"%i. ",i+1];
        }
        
        [returnDict setValue:ordinalRank forKey:[NSString stringWithFormat:@"%i",i]];
    }
    
    return returnDict;
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
    //NSLog(@"%@",placemark);
    return placemark;
}

double geoDistance(NSString * zip1, NSString * zip2){
    CLLocation *location1 = didCalculateDistance(zip1);
    CLLocation *location2 = didCalculateDistance(zip2);
    
    CLLocationDistance meters = [location1 distanceFromLocation:location2];
    return (double)(meters*0.000621371); //converting meters to miles
}

NSMutableArray * generateDistancesFromUserData(NSMutableArray* inZipArr, NSString* userZip){
    NSMutableArray* returnArr = [[NSMutableArray alloc]init];
    userZip = @"46526"; //TODO: remove this
    for (NSString* curZip in inZipArr) {
        //calculate the current distance
        [returnArr addObject:[NSNumber numberWithDouble:geoDistance(userZip, curZip)]];
    }
    return returnArr;
}

#pragma mark - Weight Calculations

//Function to update the weights in the PreferenceManager for the UserPrefs.
//Will be called with the index of the preference to update in UserPrefs along
//with the new weight for that preference.
void updateWeights(int index, float newWeight)
{
    PreferenceManager *prefMan = [PreferenceManager sharedInstance];
    NSMutableArray* userPrefs = [prefMan getAllUserPrefs];
    
    //Search for unlocked preferences
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"getLock == No"];
    NSArray* unlockedPrefs = [userPrefs filteredArrayUsingPredicate:resultPredicate];
    CGFloat totalChangeableSpace = [[unlockedPrefs valueForKeyPath:@"@sum.getWeight"] floatValue];
    CGFloat oldWeight = [[userPrefs objectAtIndex:index] getWeight];
    
    //If the preference being edited is locked, it neeeds to be added to the total changeable space
    if ([[userPrefs objectAtIndex:index] getLock]) {
        totalChangeableSpace += oldWeight;
    }
    
    //Warning, if there is no room for editing
    if (totalChangeableSpace <= oldWeight) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"All Preferences Locked" message:@"You need to unlock some of your preferences to have space to edit more." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }else {
        //Calculate new wieghts
        for (UserPreference* uP in unlockedPrefs)
        {
            if (uP != [userPrefs objectAtIndex:index]) {
                CGFloat curWeight = [uP getWeight];
                CGFloat update = (totalChangeableSpace-newWeight)*(curWeight/(totalChangeableSpace-oldWeight));
                update = MAX(update, 0.01);
                [uP setWeight:update];
            }
        }
        [[userPrefs objectAtIndex:index] setWeight:newWeight];
    }
}

NSArray * weightToWorkWith(int index)
{
    PreferenceManager *prefMan = [PreferenceManager sharedInstance];
    UserPreference* selectedPref = [[prefMan getAllUserPrefs] objectAtIndex:index];
    
    NSMutableArray* userPreferences = [NSMutableArray new];
    for (UserPreference* uP in [prefMan getAllUserPrefs])
    {
        if (uP != selectedPref) {
            [userPreferences addObject:uP];
        }
    }
    
    //Search for unlocked preferences
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"getLock == No"];
    NSArray* unlockedPrefs = [userPreferences filteredArrayUsingPredicate:resultPredicate];
    
    //Find the lowest unlocked weight and the sum of the locked weights
    CGFloat minEditableWeight = [[unlockedPrefs valueForKeyPath:@"@min.getWeight"] floatValue];
    CGFloat lockedWeight = 1 - [[unlockedPrefs valueForKeyPath:@"@sum.getWeight"] floatValue] - [selectedPref getWeight];

    //Calculate how small each unlocked preference can get
    CGFloat minUnlockedSpace = 0;
    for (UserPreference* uP in unlockedPrefs)
    {
        minUnlockedSpace += [uP getWeight]/minEditableWeight/100;
    }
    //Determine min and max allowable weight for user pref at index
    CGFloat maxWeight = 1 - minUnlockedSpace - lockedWeight;
    CGFloat minWeight = 0.01;
    
    //Check if you can't move due to too many locked screens
    if ([unlockedPrefs count] == 0)
    {
        minWeight = maxWeight;
    }
    
    //return minWeight, maxWeight wrapped in NSNumbers.
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:minWeight], [NSNumber numberWithFloat:maxWeight], nil];
}

//Calculates the weight for a new preference. Returns the weight as a float
//Pre-Condition: New Preference must be added to the PreferenceManager
void updateWeightsForNewPreference()
{
    PreferenceManager *prefMan = [PreferenceManager sharedInstance];
    NSMutableArray* userPrefs = [prefMan getAllUserPrefs];
    int prefCount = [userPrefs count];
    
    CGFloat newWeight = 1.0/prefCount;
    UserPreference* newPref = [userPrefs objectAtIndex:prefCount-1];
    
    //Calculate new wieghts
    for (UserPreference* uP in userPrefs)
    {
        if (uP != newPref) {
            CGFloat curWeight = [uP getWeight];
            CGFloat update = (1-newWeight)*(curWeight);
            [uP setWeight:update];
        }
    }
    [newPref setWeight:newWeight];
}
#pragma mark - Null Manipulations

NSMutableDictionary * takeOutNulls(NSMutableArray* inArray){
    //in order to handle nulls in the calcs, we will take out each type of NSNull or string "<null>".
    //Dictionary returns Key:"newList" value:NSMutArr without nulls
    //Key:"nullIndexs" value:NSMutArr with indecies of null vals in original string.
    NSMutableDictionary* returnDict = [[NSMutableDictionary alloc] init];
    NSMutableArray* goodArr = [[NSMutableArray alloc]init];
    NSMutableArray* indexs = [[NSMutableArray alloc] init];
    for (int i=0; i<[inArray count];i++) {
        id obj = [inArray objectAtIndex:i];
        if (!([obj isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@",obj] isEqual:@"<null>"])){
            //Then its good
            [goodArr addObject:obj];
        }
        else{
            [indexs addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    [returnDict setObject:goodArr forKey:@"newList"];
    [returnDict setObject:indexs forKey:@"nullIndexs"];
    
    return returnDict;
}

NSMutableArray * putMeanBackIn(NSMutableArray* prefVals, NSMutableArray* replaceVals){
    //create new array and at insert the mean at the indexes indicated by the replaceVals array
    NSMutableArray* returnArr = [[NSMutableArray alloc]init];
    float mean = [[prefVals valueForKeyPath:@"@avg.self"] floatValue];
    int prefValIndex = 0;
    
    for (int i=0; i<([prefVals count]+[replaceVals count]); i++) {
        if ([replaceVals containsObject:[NSNumber numberWithInt:i]]) {
            //then insert the mean
            [returnArr addObject:[NSNumber numberWithFloat:mean]];
        }
        else{
            //else insert whatever is in the prefValIndex in the prefVals. and increment
            [returnArr addObject:[prefVals objectAtIndex:prefValIndex]];
            prefValIndex++;
        }
    }
    
    return normalize(returnArr);
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
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    NSMutableArray* changedVals = [[NSMutableArray alloc]init];
    switch (chosenValue){
        case 1:
        {
            //Subtract each value from the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                [changedVals addObject:[[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])]];
//                preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            break;
        }
        case 2:
        {
            //find the middle value and subtract all other values from it, using absolute values.
            NSNumber *medianNum = [[NSNumber alloc] initWithFloat:median(preferenceValues)];
            for (int i = 0; i<[preferenceValues count]; i++){
                [changedVals addObject:[[NSNumber alloc] initWithInt:(ABS([medianNum intValue]  - [preferenceValues[i] intValue]))]];
               // preferenceValues[i] = [[NSNumber alloc] initWithInt:(ABS([medianNum intValue]  - [preferenceValues[i] intValue]))];
            }
            //Then invert the list using the highest value
            NSNumber * max = [preferenceValues valueForKeyPath:@"@max.intValue"];
            for (int i = 0; i<[preferenceValues count]; i++){
                [changedVals addObject:[[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])]];
               // preferenceValues[i] = [[NSNumber alloc] initWithInt:([max intValue]  - [preferenceValues[i] intValue])];
            }
            break;
        }
        case 3:
        {
            //Don't need to do anything since it is already in order
            break;
        }
    }
    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(changedVals);
    return putMeanBackIn(normalizedVals, replaceVals);
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
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    switch (chosenValue) {
        case 1:
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
            
        case 2:
            //Means that we don't need to change anything
            break;
    }
    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(preferenceValues);
    return putMeanBackIn(normalizedVals, replaceVals);
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
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    switch (chosenValue) {
        case 1:
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
            
        case 2:
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
            
        case 3:
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
            
        case 4:
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
            
        case 5:
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
    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(preferenceValues);
    return putMeanBackIn(normalizedVals, replaceVals);
}

NSMutableArray * normalizeFromType(NSMutableArray* preferenceValues, int chosenValue){
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    switch (chosenValue) {
        case 1:
            //Means that we want public
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] != 1){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 2:
            //Means that we want private
        {
            for (int i = 0; i<[preferenceValues count]; i++){
                if ([preferenceValues[i] intValue] != 2){
                    preferenceValues[i] = [[NSNumber alloc] initWithInt:0];
                }
            }
            break;
        }
            
        case 3:
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
    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(preferenceValues);
    return putMeanBackIn(normalizedVals, replaceVals);
}
NSMutableArray * normalizeFromDegree(NSMutableArray* preferenceValues, int chosenValue){
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    switch (chosenValue) {
        case 1:
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
            
        case 2:
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
            
        case 3:
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
            
        case 4:
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
            
        case 5:
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
    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(preferenceValues);
    return putMeanBackIn(normalizedVals, replaceVals);
}
NSMutableArray * normalizeFromReligion(NSMutableArray* preferenceValues, int chosenValue){
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    switch (chosenValue) {
        case 1:
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
            
        case 2:
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
            
        case 3:
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
            
        case 4:
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
    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(preferenceValues);
    return putMeanBackIn(normalizedVals, replaceVals);
}

NSMutableArray * normalizeFromCity(NSMutableArray* preferenceValues, int chosenValue){
    NSMutableDictionary* dataDict = takeOutNulls(preferenceValues);
    preferenceValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    //translate acceptedValue choice to what the city code is in the database
    int cityType = 0;
    switch (chosenValue) {
        case 1:
            cityType = 11;
            break;
        case 2:
            cityType = 12;
            break;
        case 3:
            cityType = 13;
            break;
        case 4:
            cityType = 21;
            break;
        case 5:
            cityType = 22;
            break;
        case 6:
            cityType = 23;
            break;
        case 7:
            cityType = 31;
            break;
        case 8:
            cityType = 32;
            break;
        case 9:
            cityType = 33;
            break;
        case 10:
            cityType = 41;
            break;
        case 11:
            cityType = 42;
            break;
        case 12:
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

    
    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(preferenceValues);
    return putMeanBackIn(normalizedVals, replaceVals);
}


//This function will convert a list of y-values of custom preference markers
//to their normalized equivalents. Returns them in the same order it was sent
NSMutableArray * normalizeFromContinuum(NSMutableArray * yValues){
    NSMutableDictionary* dataDict = takeOutNulls(yValues);
    yValues = [dataDict valueForKey:@"newList"];
    NSMutableArray* replaceVals = [dataDict valueForKey:@"nullIndexs"];
    
    //Subtract each value from the highest value
    NSNumber * max = [yValues valueForKeyPath:@"@max.floatValue"];
    for (int i = 0; i<[yValues count]; i++){
        yValues[i] = [[NSNumber alloc] initWithFloat:([max floatValue]  - [yValues[i] floatValue])];
    }

    //Normalize. Then replace everything in the replaceVals with the mean
    NSMutableArray* normalizedVals = normalize(yValues);
    return putMeanBackIn(normalizedVals, replaceVals);
}

#pragma mark - Preference & Institution Manager Calculations

//function to return dictionary of institutions that are missing data for all user prefs
NSMutableDictionary * institutionsMissingDataForUserPrefs(){
    PreferenceManager* prefMan = [PreferenceManager sharedInstance];
    InstitutionManager* instMan = [InstitutionManager sharedInstance];
    NSMutableDictionary* returnDict = [[NSMutableDictionary alloc]init];
    bool anyHadMissing = false;
    
    //load up translation for pref names
    NSString* values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    
    //get the user prefs and current institutions
    NSMutableArray* userPrefs = prefMan.userPrefs;
    
    //for each preference, see if all institutions have data for it
    for (UserPreference* curPref in userPrefs) {
        //get short name of pref
        NSString *prefShortName = [[valuesDict valueForKeyPath:[curPref getName]] objectAtIndex:0];
        
        if (!prefShortName) {
            //then we have a custom preference, so check to see if each customData dictionary in each UserInst has data
            bool anyMissingForCurrentCustomPref = false;
            for (Institution* curInst in [instMan userInstitutions]) {
                NSString* instVal = [NSString stringWithFormat:@"%@",[[curInst customData] objectForKey:[curPref getName]]];
                if (!instVal || [instVal isEqualToString:@"<null>"]) {
                    //then we have a missing institution
                    anyHadMissing = true;
                    anyMissingForCurrentCustomPref = true;
                    break;
                }
            }
            [returnDict setValue:[NSNumber numberWithBool:anyMissingForCurrentCustomPref] forKey:[curPref getName]];
        }
        else{
            //check all institutions for the normal preference
            NSMutableArray* missingInsts = [instMan getMissingDataInstitutionsForPreference:prefShortName];
            if ([missingInsts count]>0) {
                anyHadMissing = true;
                [returnDict setValue:[NSNumber numberWithBool:true] forKey:prefShortName];
            }
            else{
                [returnDict setValue:[NSNumber numberWithBool:false] forKey:prefShortName];
            }
        }
    }
    //append whether or not any had missing data
    [returnDict setValue:[NSNumber numberWithBool:anyHadMissing] forKey:@"All"];
    
    return returnDict;
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
            //do some calcs to determine actual distances based on user's zip code
            NSMutableArray* distanceVals = generateDistancesFromUserData([instMan getValuesForPreference:@"location"], [userPref getZipCode]);
            value = normalizeFromDistance(distanceVals, [userPref getPrefVal]);
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
        else if([[userPref getName] isEqualToString:@"Study Abroad Opportunities"])
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
            value = normalizeFromDegree([instMan getValuesForPreference:@"degree"], [userPref getPrefVal]);
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
            value = normalizeFromContinuum([instMan getCustomValuesForPreference:[userPref getName]]);
        }
   //     NSLog(@"%@ - %@",[userPref getName],value);
        [weightArr addObject:[NSNumber numberWithFloat:[userPref getWeight]]];
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

