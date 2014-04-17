//
//  Calculations.h
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Normalizes an NSMutableArray of NSDecimalNumbers and returns it in the same order. The normalized vales will sum to 1 and will all be between 0 and 1.
 @param prefValues
 The NSMutableArray of floating point preference values
 @return NSMutableArray of normalized NSDecimalNumbers representing preference values
 */
NSMutableArray * normalize(NSMutableArray * prefValues);

/**
 Takes a dictionary of keys=institutions and values=rankings and returns an NSMutableArray of institutions ordered descending by their correspongind value.
 @param inDict
 The Dictionary of institution-ranking key-value pairs
 @return NSMutableArray of institution names in descending order based on their value
 */
NSMutableArray * orderDictKeysDescending(NSDictionary* inDict);
NSMutableDictionary * createOrdinalDictionary(NSMutableDictionary* inDict,NSArray* inArray);

/**
 Calculates distance between two zip codes. Returns the value as number of miles in double format
 @param zip1
 Zip code of one location
 @param zip2
 Zip code of other location
 @return Double of number of miles between the zip codes.
 */
double geoDistance(NSString * zip1, NSString * zip2);


/**
 Generates rankings of all Institutions currently in the Institution manager. Returns a dictionary of key=Name of Institution, value=Cardinal Utility.
 @return NSMutableDictionary of key=Name of Institution, value=Cardinal Utility.
 */
NSMutableDictionary * generateRankings();
NSMutableDictionary * calculatePreferences(NSMutableArray * incomingInstitutions, NSMutableArray* weights); //This is a private function, never call this one

/**
 Calculates and updates the weights in the PreferenceManager to reflect changing the weight of a particular preference.
 @param index
 Integer representing the index of the UserPreference (in the PreferenceManager's list of UserPrefs) that is changing its weight
 @param newWeight
 Float (in between 0 and 1) representing the new weight of the UserPreference at the index specified by the other parameter, index.
 @return Nothing. Will update the PreferenceManager
 */
void updateWeights(int index, float newWeight);


/**
 Returns an array of two floats wrapped in NSNumbers. The first float represents the minimum allowable weight of the specified Preference in the pie chart. The second value is the max weight.
 @param index
 Integer representing the index of the UserPreference (in the PreferenceManager's list of UserPrefs) that you want to know the range of acceptable weights for the pie chart.
 @return NSArray of floats wrapped in NSNumbers. First NSNumber is minimum allowable weight. Second NSNumber is max allowable weight.
 */
NSArray * weightToWorkWith(int index);


/**
 Calculates and returns an NSMutableArray of normalized cardinal utilities based a list of y-values (used only for custom preferences).
 @param yValues
 NSMutableArray of y-values generated by the user placing the markers in the AcceptableValue view controller.
 @return Normalized list of cardinal utilities in the same order as they were passed in.
 */
NSMutableArray * normalizeFromContinuum(NSMutableArray * yValues);


/**
 Calculates and sets the weight of the newly added UserPreference in the PreferenceManager. Adjusts all other unlocked UserPreference accordingly.
 HAS THREE EXTREMELY IMPORTANT PRE-CONDITIONS!!!!!
 Pre-Condition 1: New Preference must be added to the PreferenceManager
 Pre-Condition 2: New Preference's weight must be set as "unlocked"
 Pre-Condition 3: New Preference's weight must be 0.0
 @param justAddedIndex
 Index of the newly added UserPreference in the list of UserPrefs in the PreferenceManager
 @return None.
 */
//void setANewWeight(int justAddedIndex);
void updateWeightsForNewPreference();

/**
 Determines which UserInstitutions are missing data for all user preferences. Key in the return dictionary is the short name of the preference
 @return NSMutableDictionary of key=short name of user preference, value=true if 1 or more institutions had missing data. Also returns a key = "All", where value is true if any pref had any institution with missing data. Boolean values are wrapped in NSNumbers. Get the bool value with [[returnDict objectForKey:@"All"] boolValue]
 */
NSMutableDictionary * institutionsMissingDataForUserPrefs();
