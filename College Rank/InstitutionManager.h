//
//  InstitutionManager.h
//  College Rank
//
//  Created by Jacob Levi Shetler on 3/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstitutionManager : NSObject

@property (nonatomic) NSArray* allInstitutions;
@property (nonatomic) NSMutableArray* userInstitutions;

- (void) addInstitution: (NSString *) newInstitutionName; //Initializes and adds an Institution to the userInstitutions
- (void) removeInstitution: (NSString *) institutionName; //Removes an institution with the specified name from the userInstitutions.
- (BOOL) canGoToPreferences; //Used to see if the institutions have enough data to navigate away from the first screen
- (NSArray *) searchInstitutions: (NSString *)query; //Searches the list of all institutions for the specified query. Returns all results that contain

+ (id)sharedInstance;

@end
