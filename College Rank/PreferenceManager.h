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
@property NSArray* allPrefs;

+ (id)sharedInstance;
-(NSArray*) getAllPrefs;
-(NSMutableArray*) getAllUserPrefs;
-(void) addUserPref: (UserPreference*) pref;
-(void) addUserPref: (Preference*) pref withWeight: (int) weight;
-(void) addUserPref: (Preference*) pref withWeight: (int) weight andPrefVal: (int) prefVal;
-(UserPreference*) getUserPreferenceAtIndex: (int) index;
-(Preference*) getPreferenceAtIndex: (int) index;
-(UserPreference*) getUserPreferenceForString: (NSString*) name;
-(Preference*) getPreferenceForString: (NSString*) name;
-(NSMutableArray*) getAllPrefNames;
-(BOOL) canGoToRank;



@end
