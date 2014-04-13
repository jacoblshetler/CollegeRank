//
//  PreferenceManager.m
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "PreferenceManager.h"
#import "Preference.h"
#import "UserPreference.h"
#import "DataRetreiver.h"

@implementation PreferenceManager

- (id)init {
    if (self = [super init]) {
        //we need to create the list of Preference objects here
        //Should we use preference ojbects, or a list of strings pulled from data retreiver?
        //When a preference was selected the object could be created then, this would keep the view controllers similar.
        //Also, would it make sense to have the preference class inherit from UIViewController?
        NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
        NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
        _userPrefs = [NSMutableArray new];
        _allPrefs = [[NSMutableArray alloc] init];
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

-(void) addPreferenceWithName: (NSString*) name andAcceptableValues: (NSArray*) vals
{
    [self.allPrefs addObject:[[Preference alloc] initWithName:name andAcceptableValues:vals]];
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
        if([pref getName] == name)
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
        if([pref getName] == name)
        {
            return pref;
        }
    }
    return nil;
}

-(BOOL) canGoToRank
{
    return [_userPrefs count] > 1;
}

-(NSMutableArray*) getAllPrefNames
{
#warning does not include the name of custom preferences!
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


@end
