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

@implementation PreferenceManager

- (id)init {
    if (self = [super init]) {
        //we need to create the list of Preference objects here
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

@end
