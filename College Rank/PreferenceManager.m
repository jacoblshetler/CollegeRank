//
//  PreferenceManager.m
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "PreferenceManager.h"
#import "Preference.h"
#import "InstitutionManager.h"
#import "Institution.h"
#import "UserPreference.h"
#import "DataRetreiver.h"
#import "Calculations.h"

@implementation PreferenceManager

- (id)init {
    if (self = [super init]) {
        NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
        NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
        _userPrefs = [NSMutableArray new];
        _allPrefs = [[NSMutableArray alloc] init];
        _zipCode = @"";
        _missingInstitutionsForPreferenceShortNameDictionary = [[NSMutableDictionary alloc] init];
        for(NSString *key in valuesDict)
        {
            NSMutableArray* valueArr = [[NSMutableArray alloc] init];
            for(int i=1; i<[[valuesDict objectForKey:key] count]; i++)
            {
                [valueArr addObject:[[valuesDict objectForKey:key] objectAtIndex:i]];
            }
            [_allPrefs addObject: [[Preference alloc] initWithName:key andAcceptableValues:valueArr]];
        }
    }
    return self;
}


+ (id)sharedInstance
{
    static PreferenceManager* instance = nil;
    if (instance == nil)
    {
        instance = [[self alloc] init];
    }
    return instance;
}



-(NSArray*) getAllPrefs
{
    return self.allPrefs;
}


-(NSMutableArray*) getAllUserPrefs
{
    return self.userPrefs;
}


-(void) addUserPref: (UserPreference*) pref
{
    [self.userPrefs addObject: pref];
}


-(void) addUserPref: (Preference*) pref withWeight: (float) weight
{
    [self.userPrefs addObject:[[UserPreference alloc] initWithPreference:pref andWeight:weight]];
}

-(void) addUserPref: (Preference*) pref withWeight: (float) weight andPrefVal: (int) prefVal
{
    [self.userPrefs addObject:[[UserPreference alloc] initWithPreference:pref andWeight:weight andPrefVal:prefVal]];
}

-(void) addUserPref:(Preference*) pref withAcceptableValue: (int) prefVal
{
    [self.userPrefs addObject:[[UserPreference alloc] initWithPreference:pref andPrefVal:prefVal]];
}

-(void) addUserPref:(Preference*) pref withAcceptableValue: (int) prefVal andMissingData: (NSMutableArray*) instData
{
    [self.userPrefs addObject:[[UserPreference alloc] initWithPreference:pref andPrefVal:prefVal andMissingData:instData]];
}

-(void) addPreferenceWithName: (NSString*) name andAcceptableValues: (NSArray*) vals
{
    [self.allPrefs addObject:[[Preference alloc] initWithName:name andAcceptableValues:vals]];
}

#warning Need to test removing custom interface
-(void) removeUserPrefAtIndex:(int) index
{
    UserPreference* prefToRemove = [[self userPrefs] objectAtIndex:index];
    
    //Remove from user preferences and update all the weights
    updateWeights(index, 0);
    [[self userPrefs] removeObjectAtIndex:index];
    
    //If it was a custom preference, remove it from its other locations
    if ([[prefToRemove pref] getValues]==nil) {
        [[self allPrefs] removeObject:[prefToRemove pref]];
        for (Institution* inst in [[InstitutionManager sharedInstance] userInstitutions])
        {
            [inst deleteKeyValuePairForKey:[prefToRemove getName]];
        }
    }
}


-(UserPreference*) getUserPreferenceAtIndex: (int) index
{
    return [self.userPrefs objectAtIndex:index];
}


-(Preference*) getPreferenceAtIndex: (int) index
{
    return [self.allPrefs objectAtIndex:index];
}



-(UserPreference*) getUserPreferenceForString: (NSString*) name
{
    for(UserPreference* pref in self.userPrefs)
    {
        if([[pref getName] isEqualToString:name])
        {
            return pref;
        }
    }
    return nil;
}


-(Preference*) getPreferenceForString: (NSString*) name
{
    for(Preference* pref in self.allPrefs)
    {
        if([[pref getName] isEqualToString:name])
        {
            return pref;
        }
    }
    return nil;
}

-(BOOL) canGoToRank
{
    return [self.userPrefs count] > 1;
}
-(NSMutableArray*) newPreferenceChoices
{
    //Predicate to filter out already selected preferences
    NSArray* userPrefNames = [[self userPrefs] valueForKeyPath:@"@unionOfObjects.getName"];
    NSPredicate* memberPredicate = [NSPredicate predicateWithFormat:@"NOT (Self IN %@)",userPrefNames];
    
    //Include all the current preference names
    NSMutableArray* prefChoices =[[NSMutableArray alloc] initWithArray:[[self getAllPrefNames] filteredArrayUsingPredicate:memberPredicate]];
    
    //Add Custom
    NSPredicate* customPredicate = [NSPredicate predicateWithFormat:@"Self LIKE[cd] 'Custom'"];
    NSString* name;
    if ([[userPrefNames filteredArrayUsingPredicate:customPredicate] count] == 0) {
        name = @"Custom";
    } else {                                            //Search for unused custom name
        BOOL unique = FALSE;
        int iter = 1;
        while (!unique && iter <= 10) {
            name = [NSString stringWithFormat:@"Custom %i",iter];
            NSPredicate* customXPredicate = [NSPredicate predicateWithFormat:@"Self LIKE[cd] %@",name];
            unique = ([[userPrefNames filteredArrayUsingPredicate:customXPredicate] count] == 0);
            iter ++;
        }
    }
    [prefChoices addObject:name];
    
    return prefChoices;
}

-(NSMutableArray*) getAllPrefNames
{
    NSMutableArray* tempArr = [NSMutableArray new];
    for(Preference *curPref in self.allPrefs)
    {
        [tempArr addObject:[curPref getName]];
    }
    return tempArr;
}

-(NSMutableArray*) getAllPrefWeights
{
    NSMutableArray* tempArr = [NSMutableArray new];
    for(UserPreference *curPref in self.userPrefs)
    {
        [tempArr addObject:[NSNumber numberWithFloat:[curPref getWeight]]];
    }
    return tempArr;
}

#pragma mark - Serialization Code
//get ready for serialization
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userPrefs forKey:@"userPrefs"];
    [coder encodeObject:self.allPrefs forKey:@"allPrefs"];
    [coder encodeObject:self.missingInstitutionsForPreferenceShortNameDictionary forKey:@"missing"];
    [coder encodeObject:_zipCode forKey:@"zip"];
}

//init with serialized data
- (id)initWithCoder:(NSCoder *)coder {
    self = [PreferenceManager sharedInstance];
    if (self) {
        self.userPrefs = [coder decodeObjectForKey:@"userPrefs"];
        self.allPrefs = [coder decodeObjectForKey:@"allPrefs"];
        self.missingInstitutionsForPreferenceShortNameDictionary = [coder decodeObjectForKey:@"missing"];
        _zipCode = [coder decodeObjectForKey:@"zip"];
    }
    return self;
}

-(void) calculateLocation
{
    [[CLGeocoder new] geocodeAddressString:self.zipCode completionHandler:
     ^(NSArray *placemarks, NSError *error){
         CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
         self.geoCoords = newPlacemark.location;
     }];
}



@end
