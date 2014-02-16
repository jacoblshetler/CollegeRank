//
//  PreferenceManager.h
//  College Rank
//
//  Created by Philip Bontrager on 2/15/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceManager : NSObject

@property (nonatomic, copy) NSArray* allPreferenceCategories;
@property (nonatomic, copy) NSMutableArray* userPreferenceCategories;
@property (nonatomic, copy) NSArray* userWeights;
@property (nonatomic, copy) NSMutableArray* lockedWeights;
//@property (nonatomic, copy) institutions

//userData   //User Preference Data
//dataDictionary
//getter methods for the six properties
+ (id)sharedInstance;
- (NSArray*) getAllPreferenceCategories:(NSString *) query;
- (void) addUserPreference: (NSString *) preference withData: (NSArray *) data;
//-

@end
