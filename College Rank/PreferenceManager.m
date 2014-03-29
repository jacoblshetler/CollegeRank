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
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for(NSString *key in valuesDict)
        {
            [tempArr addObject: [[Preference alloc] initWithName:key andAcceptableValues:[valuesDict objectForKey:key]]];
        }
        _allPrefs = [NSArray arrayWithArray:tempArr];
        _userPrefs = [NSMutableArray new];
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


-(void) addUserPref: (Preference*) pref withWeight: (int) weight
{
    [self.userPrefs addObject:[[UserPreference alloc] initWithPreference:pref andWeight:weight]];
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
    return [_userPrefs count] > 0;
}

@end
