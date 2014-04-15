//
//  InstitutionManager.h
//  College Rank
//
//  Created by Jacob Levi Shetler on 3/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Institution;

@interface InstitutionManager : NSObject <NSCoding>

@property (nonatomic) NSArray* allInstitutions;
@property (nonatomic) NSMutableArray* userInstitutions;

- (void) addInstitution: (NSString *) newInstitutionName; //Initializes and adds an Institution to the userInstitutions
- (void) removeInstitution: (NSString *) institutionName; //Removes an institution with the specified name from the userInstitutions.
- (BOOL) canGoToPreferences; //Used to see if the institutions have enough data to navigate away from the first screen
- (NSArray *) searchInstitutions: (NSString *)query; //Searches the list of all institutions for the specified query. Returns all results that contain
-(Institution*) getUserInstitutionForString: (NSString*) name; //retreive user instutiton based on the name
-(NSMutableArray*) getValuesForPreference: (NSString*) pref;
-(NSMutableArray*) getUserInstitutionNames;
- (NSMutableArray*) getMissingDataInstitutionsForPreference: (NSString*) prefName;
-(NSMutableArray*) getAllUserInstitutions;
+ (id)sharedInstance;

@end
