//
//  PreferenceManager.h
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Preference;
@class UserPreference;


@interface PreferenceManager : NSObject
@property NSMutableArray* userPrefs;
@property NSMutableArray* allPrefs;
@property NSMutableDictionary* missingInstitutionsForPreferenceShortNameDictionary;

+ (id)sharedInstance;
-(NSArray*) getAllPrefs;
-(NSMutableArray*) getAllUserPrefs;
-(void) addUserPref: (UserPreference*) pref;
-(void) addUserPref: (Preference*) pref withWeight: (float) weight;
-(void) addUserPref: (Preference*) pref withWeight: (float) weight andPrefVal: (int) prefVal;
-(void) addUserPref:(Preference*) pref withAcceptableValue: (int) prefVal;
-(void) addUserPref:(Preference*) pref withAcceptableValue: (int) prefVal andMissingData: (NSMutableArray*) instData;

-(void) addPreferenceWithName: (NSString*) name andAcceptableValues: (NSArray*) vals;
-(UserPreference*) getUserPreferenceAtIndex: (int) index;
-(Preference*) getPreferenceAtIndex: (int) index;
-(UserPreference*) getUserPreferenceForString: (NSString*) name;
-(Preference*) getPreferenceForString: (NSString*) name;
-(NSMutableArray*) getAllPrefNames;
-(NSMutableArray*) getAllPrefWeights;
-(BOOL) canGoToRank;
#warning needs a removePreference function



@end
