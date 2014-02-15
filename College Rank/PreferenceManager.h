//
//  PreferenceManager.h
//  College Rank
//
//  Created by Philip Bontrager on 2/15/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceManager : NSObject

@property NSArray* allPreferenceCategories;
@property NSMutableArray* userPreferenceCategories;
@property NSArray* userWeights;
@property NSMutableArray* lockedWeights;

//userData
//dataDictionary

//init
//getter methods for the six properties
- (NSArray*) getAllPreferenceCategories:(NSString *) query;
- (void) addUserPreference: (NSString *) preference withData: (NSArray *) data;

@end
